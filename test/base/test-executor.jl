# gko::Executor
for T in SUPPORTED_EXECUTOR_TYPE
    exec = GkoExecutor(T)
    
    @testset "Unit test: gko::Executor creation                      " begin
        @test exec.type == T
    end
end
