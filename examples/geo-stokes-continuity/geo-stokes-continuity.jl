using Ginkgo
using LinearAlgebra, SparseArrays
using Plots, Plots.Measures
using LaTeXStrings

ENV["GKSwstype"] = "nul";
if isdir("viz2D_out") == false
    mkdir("viz2D_out")
end;
loadpath = "./viz2D_out/";
anim = Animation(loadpath, String[]);
println("Animation directory: $(anim.dir)")

# flipping only the y-axis for the correct y=axis definition
default(size=(6300, 3300), fontfamily="Computer Modern", linewidth=4, framestyle=:box, margin=5mm, yflip=true)
scalefontsizes();
scalefontsizes(4.0);

DO_VIZ = false
with_ginkgo = true
is_free_slip = false    # set to false for no slip
const (Tv, Ti) = (Float64, Int32)


function stokes_continuity()

    # numerics
    xsize = 100000             # Horizontal size, [m]
    ysize = 100000             # Vertical size,   [m]
    Ny = 45                    # Ny
    Nx = 35                    # Nx
    dx = xsize / (Nx - 1)      # Horizontal grid step, [m]
    dy = ysize / (Ny - 1)      # Vertical grid step,   [m]

    # Arrays
    # i). basic nodes
    x = 0:dx:xsize+dx          # Horizontal coordinates of grid points, [m]
    y = 0:dy:ysize+dy          # Vertical coordinates of grid points, [m]

    # ii).  Vx-nodes
    xvx = 0:dx:xsize+dx        # Horizontal
    yvx = -dy/2:dy:ysize+dy/2  # Vertical

    # iii). Vy-nodes
    xvy = -dx/2:dx:xsize+dx/2  # Horizontal
    yvy = 0:dy:ysize+dy        # Vertical

    # iv).  P-nodes
    xpr = -dx/2:dx:xsize+dx/2  # Horizontal
    ypr = -dy/2:dy:ysize+dy/2  # Vertical

    # 4). Define physics
    #     physics: η, gy, ρ_int, ρ_ext (scalar)
    # 
    gy = 10                   # Vertical gravity [m/s^2]
    eta_int = 1e18            # [Pa · s]
    eta_ext = 1e19
    rho_int = 3200            # [kg/m^3]
    rho_ext = 3300            # [kg/m^3]

    # basic nodes: density and ETAB
    RHOB = zeros(Ny + 1, Nx + 1) # Density, [kg/m^3]
    ETAB = zeros(Ny + 1, Nx + 1) # shear

    for j in 1:1:Nx+1
        for i in 1:1:Ny+1
            # define values depending on x[j] and y[i]
            RHOB[i, j] = rho_ext   # medium
            ETAB[i, j] = eta_ext

            # distance to the centre from the given nodal point
            d = ((x[j] - xsize / 2)^2 + (y[i] - ysize / 2)^2)^0.5
            dr = ((xvy[j] - xsize / 2)^2 + (yvy[i] - ysize / 2)^2)^0.5

            if (d < 20000)
                ETAB[i, j] = eta_int
            end
            if (dr < 20000)
                RHOB[i, j] = rho_int
            end

        end
    end


    # eta in P-nodes
    ETAP = zeros(Ny + 1, Nx + 1) # normal
    for j ∈ 1:1:Nx
        for i ∈ 1:1:Ny
            ETAP[i, j] = eta_ext
            d = ((xpr[j] - xsize / 2)^2 + (ypr[i] - ysize / 2)^2)^0.5

            if (d < 20000)
                ETAP[i, j] = eta_int
            end

        end
    end

    # 5). Define global matrices
    n = (Ny + 1) * (Nx + 1) * 3   # global number of unknown
    L = zeros(n, n)                  # LHS
    R = zeros(n, 1)
    if with_ginkgo
        S = Vector{Tv}(undef, n)
    end

    # 6). Boundary condition
    if (is_free_slip == true)
        bc = -1            #   free slip   vx1 = 0, vy1 = vy2
    else
        bc = 1             #   no-slip     vx1 = 0, vy1 = -vy2
    end

    ntimesteps = 10   # change to 1 or 10

    for _ in 1:1:ntimesteps

        # Compose global matrices
        for j in 1:1:Nx+1
            for i in 1:1:Ny+1
                # global indices
                kvx = ((j - 1) * (Ny + 1) + i - 1) * 3 + 1
                kvy = kvx + 1
                kpr = kvx + 2

                # Equations for Vx
                if (j == Nx + 1)
                    # ghost nodes
                    L[kvx, kvx] = 1
                    R[kvx, 1] = 0

                elseif (i == 1 || i == Ny + 1 || j == 1 || j == Nx)
                    # real B.C.
                    L[kvx, kvx] = 1
                    R[kvx] = 0

                    if (i == 1 && j > 1 && j < Nx)
                        L[kvx, kvx+3] = bc
                    elseif (i == Ny + 1 && j > 1 && j < Nx)
                        L[kvx, kvx-3] = bc
                    end


                else
                    # internal - x-stokes
                    # η · (∂2Vx/∂x2 + ∂2Vx/∂y2) - ∂P/∂x = 0
                    #
                    #            Stencil
                    #              Vx2
                    #               |
                    #        Vy1----|----Vy3
                    #               |
                    #  Vx1---P1----Vx3----P2---Vx5
                    #               |
                    #        Vy2----|----Vy4
                    #               |
                    #              Vx4
                    # Viscosity points
                    ETA1 = ETAB[i-1, j]
                    ETA2 = ETAB[i, j]
                    ETAP1 = ETAP[i, j]
                    ETAP2 = ETAP[i, j+1]

                    L[kvx, kvx-(Ny+1)*3] = 2 * ETAP1 / dx^2                             # Vx1
                    L[kvx, kvx-3] = ETA1 / dy^2                                         # Vx2
                    L[kvx, kvx] = -2 * (ETAP1 + ETAP2) / dx^2 - (ETA1 + ETA2) / dy^2    # Vx3  
                    L[kvx, kvx+3] = ETA2 / dy^2                                         # Vx4
                    L[kvx, kvx+(Ny+1)*3] = 2 * ETAP2 / dx^2                             # Vx5

                    L[kvx, kvy-3] = ETA1 / dx / dy                                      # Vy1
                    L[kvx, kvy] = -ETA2 / dx / dy                                       # Vy2
                    L[kvx, kvy+(Ny+1)*3-3] = -ETA1 / dx / dy                            # Vy3
                    L[kvx, kvy+(Ny+1)*3] = ETA2 / dx / dy                               # Vy4

                    L[kvx, kpr] = 1 / dx                                                # P1
                    L[kvx, kpr+(Ny+1)*3] = -1 / dx                                      # P2

                    # Right part
                    R[kvx, 1] = 0
                end



                # Equations for Vy
                if (i == Ny + 1)
                    # ghost nodes
                    L[kvy, kvy] = 1
                    R[kvy, 1] = 0

                elseif (i == 1 || i == Ny || j == 1 || j == Nx + 1)
                    # real B.C.
                    L[kvy, kvy] = 1
                    R[kvy] = 0

                    if (j == 1 && i > 1 && i < Ny)
                        L[kvy, kvy+3*(Ny+1)] = bc
                    elseif (j == Nx + 1 && i > 1 && i < Ny)
                        L[kvy, kvy-3*(Ny+1)] = bc
                    end
                else
                    # internal - y-stokes
                    # η · (∂2Vy/∂x2 + ∂2Vy/∂y2) - ∂P/∂y = -ρ · gy
                    #
                    #            Stencil
                    #              Vy2
                    #               |
                    #        Vx1---PA---Vx3
                    #               |
                    # Vy1---σyx1'--Vy3--σyx2'--Vy5
                    #               |
                    #        Vx2---PB---Vx4
                    #               |
                    #              Vy4
                    ETA1 = ETAB[i, j-1]
                    ETA2 = ETAB[i, j]
                    ETAP1 = ETAP[i, j]
                    ETAP2 = ETAP[i+1, j]

                    L[kvy, kvy-(Ny+1)*3] = ETA1 / dx^2              # Vy1
                    L[kvy, kvy-3] = 2 * ETAP1 / dy^2                # Vy2
                    L[kvy, kvy] = -2 * (ETAP1 + ETAP2) / dy^2 -
                                  (ETA1 + ETA2) / dx^2              # Vy3
                    L[kvy, kvy+3] = 2 * ETAP2 / dy^2                # Vy4
                    L[kvy, kvy+(Ny+1)*3] = ETA2 / dx^2              # Vy5

                    L[kvy, kvx-(Ny+1)*3] = ETA1 / dx / dy           # Vx1
                    L[kvy, kvx+3-(Ny+1)*3] = -ETA1 / dx / dy        # Vx2
                    L[kvy, kvx] = -ETA2 / dx / dy                   # Vx3
                    L[kvy, kvx+3] = ETA2 / dx / dy                  # Vx4

                    L[kvy, kpr] = 1 / dy                            # PA
                    L[kvy, kpr+3] = -1 / dy                         # PB

                    # Right part
                    R[kvy, 1] = -RHOB[i, j] * gy
                end

                # Equations for P
                if (i == 1 || i == Ny + 1 || j == 1 || j == Nx + 1)
                    # ghost nodes
                    L[kpr, kpr] = 1
                    R[kpr, 1] = 0
                elseif (i == 2 && j == 2)
                    # real BC
                    L[kpr, kpr] = 1
                    R[kpr, 1] = 1e+9
                else
                    # internal - continuity equation
                    #  
                    #   ∂Vx/∂x + ∂Vy/∂y = 0
                    #
                    #            Stencil
                    #              Vy1
                    #               |
                    #               |
                    #       Vx1---- P ---- Vx2
                    #               |
                    #               |
                    #              Vy2
                    # Left part
                    L[kpr, kvx-(Ny+1)*3] = -1 / dx    # Vx1
                    L[kpr, kvx] = 1 / dx              # Vx2
                    L[kpr, kvy-3] = -1 / dy           # Vy1
                    L[kpr, kvy] = 1 / dy              # Vy2

                    # Right part
                    R[kpr, 1] = 0
                end
            end
        end

        # Solving global matrices
        if with_ginkgo
            # Use sprase direct solver
            Ginkgo.apply!(GkoDirectSolver(:lu_direct, sparse(L)), vec(R), S)
        else
            S = sparse(L) \ R
        end

        # Reload solution to Pr, Vx, Vy
        Vx = zeros(Ny + 1, Nx + 1)
        Vy = zeros(Ny + 1, Nx + 1)
        Pr = zeros(Ny + 1, Nx + 1)

        for j ∈ 1:1:Nx+1
            for i ∈ 1:1:Ny+1
                # global indices
                kvx = ((j - 1) * (Ny + 1) + (i - 1)) * 3 + 1
                kvy = kvx + 1
                kpr = kvx + 2

                # reload solution
                Vx[i, j] = S[kvx]
                Vy[i, j] = S[kvy]
                Pr[i, j] = S[kpr]
            end
        end

        # DEFINE ADAPTIVE TIMESTEPS
        dt = 1e+30

        # Restrictions: <= 0.5 dx  && <= 0.5 dy
        # Using the max' to define the timesteps
        Vxmax = max(abs.(Vx)...)   # using two max functions because of 2D
        Vymax = max(abs.(Vy)...)   # using two max functions because of 2D

        if (dt > (0.5 * dx) / Vxmax)
            dt = 0.5 * dx / Vxmax
        end

        if (dt > (0.5 * dy) / Vymax)
            dt = 0.5 * dy / Vymax
        end

        # here one could add advect the markers
        if DO_VIZ
            p1 = heatmap(xpr, ypr, RHOB, aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, title="Density " * L"[kg/m^3]")
            p2 = heatmap(xpr, ypr, log10.(ETAB), aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, title="Viscosity log(" * L"\eta_b)" * " " * L"[Pa\cdot s]")
            p3 = heatmap(xpr, ypr, log10.(ETAP), aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, title="Viscosity log(" * L"\eta_p)" * " " * L"[Pa\cdot s]")
            p4 = heatmap(xpr, ypr, Pr / 1e9, aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, clims=(0, 4), title="Pressure " * L"[GPa]")
            p5 = heatmap(xvx, yvx, Vx * 31556952, aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, title="Vx-velocity " * L"[m/yr]")
            p6 = heatmap(xvy, yvy, Vy * 31556952, aspect_ratio=1, xlims=(xpr[1], xpr[end]), ylims=(ypr[1], ypr[end]), c=:turbo, title="Vy-velocity " * L"[m/yr]")

            display(plot(p1, p2, p3, p4, p5, p6, layout=(2, 3)))
            frame(anim)

            # Reference values
            # FREE SLIP
            val1 = Pr[7, 5]    #  1374927109.05287
            val2 = Vx[7, 5]    # -1.75951244594608e-09
            val3 = Vy[7, 5]    #  1.79677698022029e-09


            # NO SLIP
            # val1 = Pr[7,5]    #  1374959400.70958
            # val2 = Vx[7,5]    # -5.44992100189968e-10
            # val3 = Vy[7,5]    #  5.87771380138805e-10
            println((val1, val2, val3))
        end

    end

    if DO_VIZ
        gif(anim, "geo-stokes_continuity.gif", fps=2)
    end
end

# Specify executor to be passed for matrix creation including CSR, Dense and "number" and cg solver
if with_ginkgo
    # Creates executor for a specific backend
    exec = create(:omp)
    Ginkgo.with(EXECUTOR => exec) do
        @time stokes_continuity()
    end
else
    @time stokes_continuity()
end
