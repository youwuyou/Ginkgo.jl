# gko::Executor
@testset "Unit test: gko::Executor creation                      " begin

    for T in SUPPORTED_EXECUTOR_TYPE
        # Using by default device ID 0
        exec = create(T)

        # For CPU executors only
        if supertype(typeof(exec)) == GkoCPUExecutor
            num_cores = get_num_cores(exec)
            @info "Number of cores available on current system: $num_cores"

            num_threads_per_core = get_num_threads_per_core(exec)
            @info "Number of threads per core available on current system: $num_threads_per_core"
        elseif typeof(exec) <: GkoGPUExecutor
            num = get_num_devices(exec)
            @info "Number of $T devices available on current system: $num"

            if num != 0
                get_device_id(exec)
                @info "Device ID of the current $T executor: $num"
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
end
