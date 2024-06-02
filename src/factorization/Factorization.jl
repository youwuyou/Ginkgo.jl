# gko::factorization
abstract type GkoFactorization end

mutable struct GkoParILUFactorization{Tv, Ti} <: GkoFactorization
    ptr::Ptr{Cvoid}
    """
    Generate incomplete factors using ParILU

    Keyword Arguments:
    - `iteration::Integer = 0`: The number of iterations for the factorization. Default is `0` for auto selection.
    - `skip_sorting::Bool = true`: If `true`, the `system_matrix` must be sorted. Default is `true`.
    """
    function GkoParILUFactorization{Tv, Ti}(iteration::Integer = 0, skip_sorting::Bool = false) where {Tv, Ti}
        function_name = Symbol("ginkgo_factorization_parilu_", gko_type(Tv), "_", gko_type(Ti), "_create")
        @info "Performing parallel ILU factorization"
        ptr = eval(:($API.$function_name($iteration, $skip_sorting)))   
        finalizer(delete_factorization, new{Tv, Ti}(ptr))
    end
end

################################# DESTRUCTOR ######################################
function delete_factorization(fact::GkoFactorization)
    API.ginkgo_deferred_factory_parameter_delete(fact.ptr)
end
