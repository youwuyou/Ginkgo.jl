# Low-level API

The `Ginkgo.API` submodule provides a low-level interface which closely matches the Ginkgo C API.
While these functions are not intended for general usage, they are useful for calling Ginkgo routines not yet available in `Ginkgo.jl` main interface, and is the basis for the high-level wrappers. For illustrative purpose, we use a example `api.jl` here, yet to be replaced.

```@autodocs
Modules = [Ginkgo.API]
Order = [:function]
```