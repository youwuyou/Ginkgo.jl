# base/lin_op
const SUPPORTED_ITERATIVE_SOLVER_TYPE = [:cg, :gmres, :bicgstab]
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

    # call the right C function (adds krylov_dim only for GMRES)
    function _mkptr(::Type{Tv}, solver_type::Symbol, A_ptr, exec_ptr, prec_ptr;
                    reduction::Real, maxiter::Integer, krylov_dim::Integer=0) where {Tv}
        r  = Cdouble(reduction)
        mi = Cint(maxiter)

        if solver_type == :gmres
            kd = Cint(krylov_dim)
            fname = Symbol("ginkgo_solver_gmres_", gko_type(Tv), "_create")
            return @eval $API.$fname($exec_ptr, $A_ptr, $prec_ptr, $r, $mi, $kd)
        elseif solver_type == :cg
            fname = Symbol("ginkgo_solver_cg_", gko_type(Tv), "_create")
            return @eval $API.$fname($exec_ptr, $A_ptr, $prec_ptr, $r, $mi)
        elseif solver_type == :bicgstab
            fname = Symbol("ginkgo_solver_bicgstab_", gko_type(Tv), "_create")
            return @eval $API.$fname($exec_ptr, $A_ptr, $prec_ptr, $r, $mi)
        else
            throw(ArgumentError("unsupported linear operator type $solver_type"))
        end
    end

    # Takes GkoCsr{Tv, Ti}
    function GkoIterativeSolver(
        solver_type::Symbol,
        A::GkoCsr{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2),
        krylov_dim::Int = 0
    ) where {Tv, Ti}
        solver_type in SUPPORTED_ITERATIVE_SOLVER_TYPE ||
            throw(ArgumentError("unsupported linear operator type $solver_type"))
        ptr = _mkptr(Tv, solver_type, A.ptr, executor.ptr, preconditioner.ptr;
                     reduction=reduction, maxiter=maxiter, krylov_dim=krylov_dim)
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    # Takes SparseMatrixCSC{Tv, Ti}
    function GkoIterativeSolver(
        solver_type::Symbol,
        A::SparseMatrixCSC{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[];
        preconditioner::GkoPreconditioner = GkoNonePreconditioner(),
        reduction::Real = 1e-3,
        maxiter::Int = size(A, 2),
        krylov_dim::Int = 0
    ) where {Tv, Ti}
        solver_type in SUPPORTED_ITERATIVE_SOLVER_TYPE ||
            throw(ArgumentError("unsupported linear operator type $solver_type"))
        A_dev = GkoCsr(A, executor)
        ptr = _mkptr(Tv, solver_type, A_dev.ptr, executor.ptr, preconditioner.ptr;
                     reduction=reduction, maxiter=maxiter, krylov_dim=krylov_dim)
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
        function_name = Symbol("ginkgo_solver_", solver_type, "_", gko_type(Tv), "_", gko_type(Ti), "_create")
        ptr = eval(:($API.$function_name($executor.ptr, $A.ptr)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end

    function GkoDirectSolver(
        solver_type::Symbol,
        A::SparseMatrixCSC{Tv, Ti},
        executor::GkoExecutor = EXECUTOR[]    ) where {Tv, Ti}
        solver_type in SUPPORTED_DIRECT_SOLVER_TYPE || throw(ArgumentError("unsupported linear operator type $solver_type"))
        function_name = Symbol("ginkgo_solver_", solver_type, "_", gko_type(Tv), "_", gko_type(Ti), "_create")
        # Convert SparseMatrixCSC{Float64, Int64} => GkoCsr{Tv, Ti}
        A_device = GkoCsr(A, executor)
        ptr = eval(:($API.$function_name($executor.ptr, $A_device.ptr)))
        finalizer(delete_linop, new{Tv}(ptr, solver_type))
    end    
end