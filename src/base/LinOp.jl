# base/lin_op
const SUPPORTED_SOLVER_TYPE = [:cg, :gmres]

mutable struct GkoLinOp{T}
    ptr::Ptr{Cvoid}
    type::Symbol

    ############################# CONSTRUCTOR ####################################
    # Takes GkoCsr{Tv, Ti}
    function GkoLinOp(
        solver_type::Symbol,
        A::GkoCsr{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2)
    ) where {Tv, Ti}
        solver_type in SUPPORTED_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_preconditioned_" , gko_type(Tv), "_create")

        @info "Creating $solver_type solver"
        ptr = eval(:($API.$function_name($executor.ptr, $A.ptr, $preconditioner.ptr, $reduction, $maxiter)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    # Takes SparseMatrixCSC{Tv, Ti}
    function GkoLinOp(
        solver_type::Symbol,
        A::SparseMatrixCSC{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2)
    ) where {Tv, Ti}
        solver_type in SUPPORTED_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_preconditioned_" , gko_type(Tv), "_create")
        # Convert SparseMatrixCSC{Float64, Int64} => GkoCsr{Tv, Ti}
        A_device = GkoCsr(A, executor)

        @info "Creating $solver_type solver"
        ptr = eval(:($API.$function_name($executor.ptr, $A_device.ptr, $preconditioner.ptr, $reduction, $maxiter)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    ############################# DESTRUCTOR ####################################
    function delete_linop(linop::GkoLinOp)
        @warn "Calling the destructor for GkoLinOp!"
        API.ginkgo_linop_delete(linop.ptr)
    end
end

# Takes GkoDense{T}
function apply!(solver::GkoLinOp, b::GkoDense{T}, x::GkoDense{T}) where {T}
    eval(:($API.ginkgo_linop_apply($solver.ptr, $b.ptr, $x.ptr)))
end

# Takes Vector{T}
function apply!(solver::GkoLinOp, b::Vector{T}, x::Vector{T}, executor::GkoExecutor = EXECUTOR[]) where {T}
    # Convert Vector{T} => GkoDense{T}
    x_device = GkoDense(x, executor)
    b_device = GkoDense(b, executor)
    eval(:($API.ginkgo_linop_apply($solver.ptr, $b_device.ptr, $x_device.ptr)))
end