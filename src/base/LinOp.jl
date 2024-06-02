# base/lin_op
const SUPPORTED_ITERATIVE_SOLVER_TYPE = [:cg, :gmres]
const SUPPORTED_DIRECT_SOLVER_TYPE    = [:spd_direct, :lu_direct]

############################### ABSTRACT LINOP ####################################
abstract type GkoLinOp end

function apply!(solver::GkoLinOp, b::GkoDense{T}, x::GkoDense{T}) where {T}
    # Takes GkoDense{T}
    eval(:($API.ginkgo_linop_apply($solver.ptr, $b.ptr, $x.ptr)))
end

function apply!(solver::GkoLinOp, b::Vector{T}, x::Vector{T}, executor::GkoExecutor = EXECUTOR[]) where {T}
    # Takes Vector{T}
    # Convert Vector{T} => GkoDense{T}
    x_device = GkoDense(x, executor)
    b_device = GkoDense(b, executor)
    eval(:($API.ginkgo_linop_apply($solver.ptr, $b_device.ptr, $x_device.ptr)))
end

function delete_linop(linop::GkoLinOp)
    API.ginkgo_linop_delete(linop.ptr)
end

############################# ITERATIVE SOLVERS ####################################
mutable struct GkoIterativeSolver{T} <: GkoLinOp
    ptr::Ptr{Cvoid}
    type::Symbol

    # Takes GkoCsr{Tv, Ti}
    function GkoIterativeSolver(
        solver_type::Symbol,
        A::GkoCsr{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2)
    ) where {Tv, Ti}
        solver_type in SUPPORTED_ITERATIVE_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_preconditioned_" , gko_type(Tv), "_create")
        ptr = eval(:($API.$function_name($executor.ptr, $A.ptr, $preconditioner.ptr, $reduction, $maxiter)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    # Takes SparseMatrixCSC{Tv, Ti}
    function GkoIterativeSolver(
        solver_type::Symbol,
        A::SparseMatrixCSC{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2)
    ) where {Tv, Ti}
        solver_type in SUPPORTED_ITERATIVE_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_preconditioned_" , gko_type(Tv), "_create")
        # Convert SparseMatrixCSC{Float64, Int64} => GkoCsr{Tv, Ti}
        A_device = GkoCsr(A, executor)
        ptr = eval(:($API.$function_name($executor.ptr, $A_device.ptr, $preconditioner.ptr, $reduction, $maxiter)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end
end

############################# DIRECT SOLVERS ####################################
mutable struct GkoDirectSolver{T} <: GkoLinOp
    ptr::Ptr{Cvoid}
    type::Symbol

    # Takes GkoCsr{Tv, Ti}
    function GkoDirectSolver(
        solver_type::Symbol,
        A::GkoCsr{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[]
    ) where {Tv, Ti}
        solver_type in SUPPORTED_DIRECT_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_", gko_type(Tv), "_", gko_type(Ti), "_create")
        ptr = eval(:($API.$function_name($executor.ptr, $A.ptr)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    function GkoDirectSolver(
        solver_type::Symbol,
        A::SparseMatrixCSC{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[]    ) where {Tv, Ti}
        solver_type in SUPPORTED_DIRECT_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_linop_", solver_type, "_", gko_type(Tv), "_", gko_type(Ti), "_create")
        # Convert SparseMatrixCSC{Float64, Int64} => GkoCsr{Tv, Ti}
        A_device = GkoCsr(A, executor)
        ptr = eval(:($API.$function_name($executor.ptr, $A_device.ptr)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end    
end