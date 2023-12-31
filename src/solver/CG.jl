# gko::solver::Cg<T>
function cg!(x::Ginkgo.GkoDense{Tv}, A::Ginkgo.GkoCsr{Tv, Ti}, b::Ginkgo.GkoDense{Tv}, executor::GkoExecutor = EXECUTOR[];
    abstol::Real = zero(real(eltype(b))),
    reltol::Real = sqrt(eps(real(eltype(b)))),
    reduction::Real = 1e-3,
    maxiter::Int = size(A, 2),
    # log::Bool = false,
    # statevars::CGStateVariables = CGStateVariables(zero(x), similar(x), similar(x)),
    # verbose::Bool = false,
    # Pl = Identity(),
    kwargs...) where {Tv, Ti}

    # Store the result in the x
    API.ginkgo_solver_cg_solve(executor.ptr, A.ptr, b.ptr, x.ptr, maxiter, reduction)
end