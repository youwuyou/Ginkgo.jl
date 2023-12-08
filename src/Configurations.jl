"""
    version()

Obtain the version information and the supported modules of the underlying Ginkgo library.
"""
function version()
    @info "Using precompiled Ginkgo library from C++ source code"
    API.ginkgo_version_get()
end