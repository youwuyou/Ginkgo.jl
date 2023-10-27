"""
    get_version()

Obtain the version information and the supported modules of the underlying Ginkgo library.
"""
function get_version()
    @info "Using precompiled Ginkgo library from C++ source code"
    API.ginkgo_get_version()
end