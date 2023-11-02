"""
    versioninfo()

Obtain the version information and the supported modules of the underlying Ginkgo library.
"""
function versioninfo()
    @info "Using precompiled Ginkgo library from C++ source code"
    API.ginkgo_version_get()
end