module API

using CEnum

libsimpson = joinpath(ENV["LIBSIMPSON_DIR"], "libsimpson.so")

"""
    integrate(a, b, bins, _function)

Integrate over a given function given by a function pointer `function`

### Parameters
* `a`: double
* `b`: double
* `bins`: a positive integer
* `function`: a pointer to a function
### Returns
double
"""
function integrate(a, b, bins, _function)
    ccall((:integrate, libsimpson), Cdouble, (Cdouble, Cdouble, Cuint, Ptr{Cvoid}), a, b, bins, _function)
end

"""
    get_version()

Get the version of the package
"""
function get_version()
    ccall((:get_version, libsimpson), Cvoid, ())
end

# exports
const PREFIXES = ["CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
