const SUPPORTED_EXECUTOR_TYPE = [:omp, :reference#=, :cuda, :hip, :dpcpp=#]

"""
    create!(executor_type::Symbol)

Creation of the executor of a specified executor type.

# Arguments
- `executor_type::Symbol`: One of the executor types to create out of $SUPPORTED_EXECUTOR_TYPE
"""
function create!(executor_type::Symbol)
    executor_type in SUPPORTED_EXECUTOR_TYPE || throw(ArgumentError("unsupported executor type $executor_type"))

    function_name = Symbol("ginkgo_create_executor_", executor_type)
    @info "Creating $executor_type executor"
    return eval(:($API.$function_name()))
end