using Ginkgo
using Ferrite
using SparseArrays
using MatrixMarket

with_ginkgo = true

function assemble_element!(Ke::Matrix, fe::Vector, cellvalues::CellScalarValues)
    n_basefuncs = getnbasefunctions(cellvalues)
    # Reset to 0
    fill!(Ke, 0)
    fill!(fe, 0)
    # Loop over quadrature points
    for q_point in 1:getnquadpoints(cellvalues)
        # Get the quadrature weight
        dΩ = getdetJdV(cellvalues, q_point)
        # Loop over test shape functions
        for i in 1:n_basefuncs
            δu  = shape_value(cellvalues, q_point, i)
            ∇δu = shape_gradient(cellvalues, q_point, i)
            # Add contribution to fe
            fe[i] += δu * dΩ
            # Loop over trial shape functions
            for j in 1:n_basefuncs
                ∇u = shape_gradient(cellvalues, q_point, j)
                # Add contribution to Ke
                Ke[i, j] += (∇δu ⋅ ∇u) * dΩ
            end
        end
    end
    return Ke, fe
end

function assemble_global(cellvalues::CellScalarValues, K::SparseMatrixCSC, dh::DofHandler)
    # Allocate the element stiffness matrix and element force vector
    n_basefuncs = getnbasefunctions(cellvalues)
    Ke = zeros(n_basefuncs, n_basefuncs)
    fe = zeros(n_basefuncs)
    # Allocate global force vector f
    f = zeros(ndofs(dh))
    # Create an assembler
    assembler = start_assemble(K, f)
    # Loop over all cels
    for cell in CellIterator(dh)
        # Reinitialize cellvalues for this cell
        reinit!(cellvalues, cell)
        # Compute element contribution
        assemble_element!(Ke, fe, cellvalues)
        # Assemble Ke and fe into K and f
        assemble!(assembler, celldofs(cell), Ke, fe)
    end
    return K, f
end

function ginkgo_solve!(u, K, f)
    # Print ginkgo library version
    Ginkgo.version()
    # Creates executor for a specific backend
    exec = create(:omp)

    # STEP 1: convert Vector{T} => GkoDense{T}, provide initial guess
    u_device = GkoDense(u, exec)
    f_device = GkoDense(f, exec)

    # STEP 2: convert SparseMatrixCSC{Float64, Int64} => GkoCsr{Tv, Ti}
    # FIXME: naive try
    MatrixMarket.mmwrite("K.mtx", K)
    K_device = GkoCsr{Float64, Int64}("K.mtx", exec)

    # STEP 3-1: primitively, use this old cg! that takes GkoDense{Tv} and GkoCsr{Tv, Ti} directly
    cg!(u_device, K_device, f_device, exec; maxiter = 20, reduction = 1.0e-5)

    # STEP 3-2: have a new cg! that takes
    # Vector{T}, SparseMatrixCSC{Float64, Int64}
    # and the executor and runs directly

    # STEP 4: Convert u_gpu back to Vector{Float64} for plotting
    #         convert GkoDense{T}
    #              => Vector{Float64}
    # somehow it is working directly??
    copyto!(u, u_device)
end

############################# Using Ferrite to assemble matrix ####################################
grid = generate_grid(Quadrilateral, (20, 20));

dim = 2
ip = Lagrange{dim, RefCube, 1}()
qr = QuadratureRule{dim, RefCube}(2)
cellvalues = CellScalarValues(qr, ip);

dh = DofHandler(grid)
add!(dh, :u, 1)
close!(dh);

K = create_sparsity_pattern(dh)

ch = ConstraintHandler(dh);

∂Ω = union(
    getfaceset(grid, "left"),
    getfaceset(grid, "right"),
    getfaceset(grid, "top"),
    getfaceset(grid, "bottom"),
);

dbc = Dirichlet(:u, ∂Ω, (x, t) -> 0)
add!(ch, dbc);

close!(ch)

K, f = assemble_global(cellvalues, K, dh);

# To account for boundary conditions
apply!(K, f, ch)

########################## Solve the LSE (not) using ginkgo solver ##############################
if with_ginkgo
    u = Vector{Float64}(undef, length(f)); fill!(u, 0.0)
    ginkgo_solve!(u, K, f)
else
    u = K \ f
end

#################################### Visualization ################################################
vtk_grid("heat_equation", dh) do vtk
    vtk_point_data(vtk, dh, u)
end