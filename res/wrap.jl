using Clang.Generators
import ginkgo_jll

# local ginkgo headers
# include_dir = normpath(ENV["GINKGO_INCLUDE_DIR"], "ginkgo")

# JLL
include_dir = normpath(ginkgo_jll.artifact_dir, "usr", "local", "include", "ginkgo")
isdir(include_dir) || error("$include_dir does not exist")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "wrap.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-DBUILD_SHARED_LIBS")

# specifying C API header to parse
headers = [joinpath(include_dir, header) for header in readdir(include_dir) if startswith(header, "c_api")]


println(headers)

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
