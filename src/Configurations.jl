"""
    version()

Obtain the version information and the supported modules of the underlying Ginkgo library.

# External links
$(_doc_external("gko::matrix::Dense<T>", "classgko_1_1version__info"))
"""
function version()
    @info "Using precompiled Ginkgo library from C++ source code"
    API.ginkgo_version_get()
end