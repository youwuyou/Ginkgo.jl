# gko::factorization
abstract type GkoFactorization end

mutable struct GkoParILUFactorization{Tv, Ti} <: GkoFactorization
    ptr::Ptr{Cvoid}
    ############################# CONSTRUCTOR ####################################
    function GkoParILUFactorization{Tv, Ti}(iteration::Integer) where {Tv, Ti}
        function_name = Symbol("ginkgo_factorization_parilu_", gko_type(Tv), "_", gko_type(Ti), "_create")
        @info "Performing parallel ILU factorization"
        ptr = eval(:($API.$function_name($iteration)))   
        finalizer(delete_factorization, new{Tv, Ti}(ptr))
    end
end

################################# DESTRUCTOR ######################################
function delete_factorization(fact::GkoFactorization)
    @warn "Calling the destructor for GkoParILUFactorization"
    API.ginkgo_deferred_factory_parameter_delete(fact.ptr)
end
