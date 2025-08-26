
# Low-level API {#Low-level-API}

The `Ginkgo.API` submodule provides a low-level interface which closely matches the Ginkgo C API. While these functions are not intended for general usage, they are useful for calling Ginkgo routines not yet available in `Ginkgo.jl` main interface, and is the basis for the high-level wrappers. For illustrative purpose, we use a example `api.jl` here, yet to be replaced.
<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_dim2_cols_get-Tuple{Any}' href='#Ginkgo.API.ginkgo_dim2_cols_get-Tuple{Any}'><span class="jlbinding">Ginkgo.API.ginkgo_dim2_cols_get</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_dim2_cols_get(dim)
```


Obtains the value of the second element of a gko::dim&lt;2&gt; type

**Parameters**
- `dim`: An object of [`gko_dim2_st`](/reference/low-level-api#Ginkgo.API.gko_dim2_st) type
  

**Returns**

size_t Second dimension


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L72-L81" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_dim2_create-Tuple{Any, Any}' href='#Ginkgo.API.ginkgo_dim2_create-Tuple{Any, Any}'><span class="jlbinding">Ginkgo.API.ginkgo_dim2_create</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_dim2_create(rows, cols)
```


Allocates memory for a C-based reimplementation of the gko::dim&lt;2&gt; type

**Parameters**
- `rows`: First dimension
  
- `cols`: Second dimension
  

**Returns**

[`gko_dim2_st`](/reference/low-level-api#Ginkgo.API.gko_dim2_st) C struct that contains members of the gko::dim&lt;2&gt; type


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L43-L53" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_dim2_rows_get-Tuple{Any}' href='#Ginkgo.API.ginkgo_dim2_rows_get-Tuple{Any}'><span class="jlbinding">Ginkgo.API.ginkgo_dim2_rows_get</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_dim2_rows_get(dim)
```


Obtains the value of the first element of a gko::dim&lt;2&gt; type

**Parameters**
- `dim`: An object of [`gko_dim2_st`](/reference/low-level-api#Ginkgo.API.gko_dim2_st) type
  

**Returns**

size_t First dimension


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L58-L67" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_executor_delete-Tuple{Any}' href='#Ginkgo.API.ginkgo_executor_delete-Tuple{Any}'><span class="jlbinding">Ginkgo.API.ginkgo_executor_delete</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_executor_delete(exec_st_ptr)
```


Deallocates memory for an executor on targeted device.

**Parameters**
- `exec_st_ptr`: Raw pointer to the shared pointer of the executor to be deleted
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L86-L93" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_matrix_csr_f32_i32_apply-NTuple{5, Any}' href='#Ginkgo.API.ginkgo_matrix_csr_f32_i32_apply-NTuple{5, Any}'><span class="jlbinding">Ginkgo.API.ginkgo_matrix_csr_f32_i32_apply</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)
```


Performs an SpMM product

**Parameters**
- `mat_st_ptr`:
  
- `alpha`:
  
- `x`:
  
- `beta`:
  
- `y`:
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L361-L372" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.ginkgo_version_get-Tuple{}' href='#Ginkgo.API.ginkgo_version_get-Tuple{}'><span class="jlbinding">Ginkgo.API.ginkgo_version_get</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
ginkgo_version_get()
```


This function is a wrapper for obtaining the version of the ginkgo library


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L382-L386" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.gko_dim2_st' href='#Ginkgo.API.gko_dim2_st'><span class="jlbinding">Ginkgo.API.gko_dim2_st</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
gko_dim2_st
```


Struct implements the gko::dim&lt;2&gt; type


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L18-L22" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.gko_executor' href='#Ginkgo.API.gko_executor'><span class="jlbinding">Ginkgo.API.gko_executor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Type of the pointer to the wrapped [`gko_executor_st`](/reference/low-level-api#Ginkgo.API.gko_executor_st) struct


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L13-L15" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.API.gko_executor_st' href='#Ginkgo.API.gko_executor_st'><span class="jlbinding">Ginkgo.API.gko_executor_st</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Struct containing the shared pointer to a ginkgo executor


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/78ac16ad24be5684e4363e679998067cc47b622f/src/api.jl#L8-L10" target="_blank" rel="noreferrer">source</a></Badge>

</details>

