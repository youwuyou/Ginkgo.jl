# gko::Executor
@testset "Unit test: gko::Executor creation                      " begin

    for T in SUPPORTED_EXECUTOR_TYPE
        exec = GkoExecutor(T)
        @test exec.type == T
        if T != :reference && T != :omp
            num = get_num_devices(T)
            @info "Number of $T devices available on current system: $num"
        end
    end
end
