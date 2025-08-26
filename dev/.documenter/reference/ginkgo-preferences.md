
# GkoPreferences {#GkoPreferences}

`GkoPreferences` is a submodule of [Ginkgo.jl](https://github.com/youwuyou/Ginkgo.jl). It provides several useful functions to check for important information about the underlying [ginkgo_jll.jl](https://github.com/JuliaBinaryWrappers/ginkgo_jll.jl) and utilizes [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl) package for overriding the default binaries used for Ginkgo.jl. 

These choices are compile-time constants, any changes require a Julia restart.
<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoPreferences.diagnostics-Tuple{}' href='#Ginkgo.GkoPreferences.diagnostics-Tuple{}'><span class="jlbinding">Ginkgo.GkoPreferences.diagnostics</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
diagnostics()
```


Checking if the artifact is avaliable for current platform. It returns false if `best_wrapper === nothing`


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/ec5d986b9677d431940287e838cca61593dfe816/src/preferences.jl#L34-L38" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoPreferences.locate-Tuple{}' href='#Ginkgo.GkoPreferences.locate-Tuple{}'><span class="jlbinding">Ginkgo.GkoPreferences.locate</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
locate()
```


Fetch locations of binaries being used by Ginkgo.jl


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/ec5d986b9677d431940287e838cca61593dfe816/src/preferences.jl#L15-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoPreferences.preferences-Tuple{}' href='#Ginkgo.GkoPreferences.preferences-Tuple{}'><span class="jlbinding">Ginkgo.GkoPreferences.preferences</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
preferences()
```


Checking if paths to ginkgo binaries are overwritten in `LocalPreferences.toml` file.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/ec5d986b9677d431940287e838cca61593dfe816/src/preferences.jl#L47-L51" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoPreferences.use_jll_binary!-Tuple{}' href='#Ginkgo.GkoPreferences.use_jll_binary!-Tuple{}'><span class="jlbinding">Ginkgo.GkoPreferences.use_jll_binary!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
use_jll_binary!()
```


Change library paths used by Ginkgo.jl to artifacts provided by [ginkgo_jll.jl](https://github.com/JuliaBinaryWrappers/ginkgo_jll.jl).

::: tip Note

You will need to restart Julia to use the new library.

:::

::: warning Warning

Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update your version of Julia, or add ginkgo_jll as a direct dependency to your project.

:::


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/ec5d986b9677d431940287e838cca61593dfe816/src/preferences.jl#L105-L117" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoPreferences.use_system_binary!-Tuple{Any}' href='#Ginkgo.GkoPreferences.use_system_binary!-Tuple{Any}'><span class="jlbinding">Ginkgo.GkoPreferences.use_system_binary!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
use_system_binary!(libpath; force=true, debug=false)
```


Change library paths used by Ginkgo.jl to system binaries located at `libpath`.

The override keyword can be either:
- `force`, See `Preferences.set_preferences!` for the `force` keyword.
  
- `debug`, This argument needs to be set to `true` for using binaries built in debug mode
  

::: tip Note

You will need to restart Julia to use the new library.

:::

::: warning Warning

Due to a bug in Julia (until 1.6.5 and 1.7.1), setting preferences in transitive dependencies is broken (https://github.com/JuliaPackaging/Preferences.jl/issues/24). To fix this either update your version of Julia, or add ginkgo_jll as a direct dependency to your project.

:::


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/ec5d986b9677d431940287e838cca61593dfe816/src/preferences.jl#L64-L80" target="_blank" rel="noreferrer">source</a></Badge>

</details>

