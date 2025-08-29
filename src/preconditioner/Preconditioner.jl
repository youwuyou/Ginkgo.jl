# gko::preconditioner
abstract type GkoPreconditioner end

mutable struct GkoNonePreconditioner <: GkoPreconditioner
    ptr::Ptr{Cvoid}
    ############################# CONSTRUCTOR ####################################
    function GkoNonePreconditioner()
        @info "Creating dummy variable when no preconditioner is used"
        ptr = eval(:($API.gko_preconditioner_none_create()))
        finalizer(delete_preconditioner, new(ptr))
    end
end

mutable struct GkoJacobiPreconditioner{Tv, Ti} <: GkoPreconditioner
    ptr::Ptr{Cvoid}
    ############################# CONSTRUCTOR ####################################
    function GkoJacobiPreconditioner{Tv,Ti}(blocksize::Integer) where {Tv, Ti}
        function_name = Symbol("gko_preconditioner_jacobi_", gko_type(Tv), "_", gko_type(Ti), "_create")
        @info "Creating Jacobi preconditioner"
        ptr = eval(:($API.$function_name($blocksize)))
        finalizer(delete_preconditioner, new{Tv, Ti}(ptr))
    end
end

mutable struct GkoILUPreconditioner{Tv, Ti} <: GkoPreconditioner
    ptr::Ptr{Cvoid}
    ############################# CONSTRUCTOR ####################################
    function GkoILUPreconditioner{Tv,Ti}(fact::GkoFactorization) where {Tv, Ti}
        function_name = Symbol("gko_preconditioner_ilu_", gko_type(Tv), "_", gko_type(Ti), "_create")
        @info "Creating ILU preconditioner"
        ptr = eval(:($API.$function_name($fact.ptr)))
        finalizer(delete_preconditioner, new{Tv, Ti}(ptr))
    end
end


################################# DESTRUCTOR ######################################
function delete_preconditioner(precond::GkoPreconditioner)
    API.gko_deferred_factory_parameter_delete(precond.ptr)
end