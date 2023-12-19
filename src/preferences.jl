module GkoPreferences
using Preferences

try
    import ginkgo_jll
catch err
    @debug """
    import ginkgo_jll failed.
    Consider using `Ginkgo.GkoPreferences.use_jll_binary()` to repair.
    """
end

const LIBS = [:libginkgo, :libginkgo_reference, :libginkgo_omp, :libginkgo_cuda, :libginkgo_hip, :libginkgo_dpcpp, :libginkgo_device]

"""
    locate()

Fetch locations of binaries being used by Ginkgo.jl
"""
function locate()
    @info(
        "Location of binaries being used by Ginkgo.jl",
        ginkgo_jll.find_artifact_dir(),
        ginkgo_jll.get_libginkgo_path(),
        ginkgo_jll.get_libginkgo_reference_path(),
        ginkgo_jll.get_libginkgo_omp_path(),
        ginkgo_jll.get_libginkgo_cuda_path(),
        ginkgo_jll.get_libginkgo_hip_path(),
        ginkgo_jll.get_libginkgo_dpcpp_path(),
        ginkgo_jll.get_libginkgo_device_path()
    )
end

"""
    diagnostics()

Checking if the artifact is avaliable for current platform. It returns false if `best_wrapper === nothing`
"""
function diagnostics()
    if ginkgo_jll.is_available()
        println("ginkgo_jll.jl supports current platform.")
    else
        println("ginkgo_jll.jl does not support current platform yet, see supported platform under https://github.com/JuliaBinaryWrappers/ginkgo_jll.jl")
    end
end

"""
    preferences()

Checking if paths to ginkgo binaries are overwritten in `LocalPreferences.toml` file.
"""
function preferences()
    for lib in LIBS
        if has_preference(ginkgo_jll, string(lib,"_path")) 
            set_path = load_preference(ginkgo_jll, string(lib,"_path"))
            println("Path to $lib set to $set_path")
        else
            println("No preferences set for $lib")
        end
    end
end


"""
    use_system_binary!(libpath; force=true, debug=false)

Change library paths used by Ginkgo.jl to system binaries located at `libpath`.

The override keyword can be either:
* `force`, See `Preferences.set_preferences!` for the `force` keyword.
* `debug`, This argument needs to be set to `true` for using binaries built in debug mode

!!! note
    You will need to restart Julia to use the new library.

!!! warning
    Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies
    is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update
    your version of Julia, or add ginkgo_jll as a direct dependency to your project.
"""
function use_system_binary!(libpath; force=false, debug=false)
    ispath(libpath) || error("ginkgo library path $libpath not found")
    for lib in LIBS
        debug ? lib_filename = string(lib, "d.", Base.Libc.Libdl.dlext) : lib_filename = string(lib, ".", Base.Libc.Libdl.dlext)
        Base.Libc.Libdl.find_library(lib_filename, [libpath]) != "" || error("$lib_filename is not found in $libpath or cannot be opened. Additionally, if you compiled your ginkgo library in debug mode, please set debug=true")
        set_preferences!(
            ginkgo_jll,
            string(lib, "_path") => normpath(libpath, lib_filename);
            force=force,
        )
    end

    @warn "ginkgo library paths changed, you will need to restart Julia for the change to take effect" libpath

    if VERSION <= v"1.6.5" || VERSION == v"1.7.0"
        @warn """
        Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies
        is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update
        your version of Julia, or add ginkgo_jll as a direct dependency to your project.
        """
    end
end


"""
    use_jll_binary!()

Change library paths used by Ginkgo.jl to artifacts provided by [ginkgo_jll.jl](https://github.com/JuliaBinaryWrappers/ginkgo_jll.jl).

!!! note
    You will need to restart Julia to use the new library.

!!! warning
    Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies
    is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update
    your version of Julia, or add ginkgo_jll as a direct dependency to your project.
"""
function use_jll_binary!()
    for lib in LIBS
        delete_preferences!(
            ginkgo_jll,
            string(lib, "_path");
            force=true,
        )
    end

    @warn "ginkgo library paths changed, you will need to restart Julia for the change to take effect" ginkgo_jll.find_artifact_dir()

    if VERSION <= v"1.6.5" || VERSION == v"1.7.0"
        @warn """
        Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies
        is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update
        your version of Julia, or add ginkgo_jll as a direct dependency to your project.
        """
    end
end

end # module