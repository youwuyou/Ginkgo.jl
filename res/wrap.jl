using Clang.Generators
import ginkgo_jll
import REPL # for radio menu

# check existence of the include directory & c_api.h
function validate(path)
    ispath(path) || error("ginkgo library path $path not found")
    isfile(joinpath(path, "c_api.h")) || error("c_api.h was not found in $path")
    return path
end

# get the header directory using RadioMenu
menu = REPL.TerminalMenus.RadioMenu(["Yes", "No"])
choice_index = REPL.TerminalMenus.request("Do you want to use the default ginkgo headers from ginkgo_jll? [Yes/No]: ", menu)

if choice_index == 2  # "No" selected
    # check if the environment variable is set
    env_var = get(ENV, "GINKGO_INCLUDE_DIR", nothing)
    if env_var !== nothing && env_var != ""
        @info("Using GINKGO_INCLUDE_DIR from environment: $env_var")
        custom_dir = normpath(env_var, "ginkgo")
        header_dir = validate(custom_dir)
    else
        println("Environment variable GINKGO_INCLUDE_DIR is not set. Please specify the path to the directory where c_api.h locates: ")
        custom_dir = readline()
        @info "Using ginkgo headers within the provided include directory: $custom_dir"
        header_dir = validate(custom_dir)
    end
else  # "Yes" selected
    @info "Using ginkgo headers referred by ginkgo_jll"
    default_dir = normpath(ginkgo_jll.artifact_dir, "include", "ginkgo")
    header_dir = validate(default_dir)
end

# wrapper generator options
options = load_options(joinpath(@__DIR__, "wrap.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$header_dir")
push!(args, "-DBUILD_SHARED_LIBS")

# specifying C API header to parse
headers = [joinpath(header_dir, header) for header in readdir(header_dir) if startswith(header, "c_api")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)



# TODO: change joinpath to normpath?