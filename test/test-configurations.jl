# Testing if information of the Ginkgo library can be retrived correctly
@testset "Unit test: retrieving library information            " begin
    @test_logs (:info,"Using precompiled Ginkgo library from C++ source code") Ginkgo.versioninfo()
end