# gko::Executor
@testset "Unit test: gko::Executor creation                      " begin

    for T in SUPPORTED_EXECUTOR_TYPE
        # Using by default device ID 0
        exec = create(T)

        # For CPU executors only
        if supertype(typeof(exec)) == GkoCPUExecutor


        elseif typeof(exec) <: GkoGPUExecutor
            num = get_num_devices(exec)
            @info "Number of $T devices available on current system: $num"

            if typeof(exec) <: GkoGPUItemExecutor
                max_subgroup_size = get_max_subgroup_size(exec)
                @info "Maximal subgroup size available on current system: $max_subgroup_size"

                max_workgroup_size = get_max_workgroup_size(exec)
                @info "Maximal workgroup size available on current system: $max_workgroup_size"

                num_computing_units = get_num_computing_units(exec)
                @info "Number of computing units available on current system: $num_computing_units"
            end

        end
    end
end
