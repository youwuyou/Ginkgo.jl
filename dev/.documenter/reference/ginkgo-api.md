
# Ginkgo.jl API {#Ginkgo.jl-API}


<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoCsr' href='#Ginkgo.GkoCsr'><span class="jlbinding">Ginkgo.GkoCsr</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
GkoCsr{Tv, Ti} <: AbstractMatrix{Tv, Ti}
```


A type for representing sparse matrix and vectors in CSR format. Alias for `gko_matrix_csr_eltype_indextype_st` in C API.     where `eltype` is one of the DataType[Float32] and `indextype` is one of the DataType[Int32].     For constructing a matrix, it is necessary to provide an [`GkoExecutor`](/reference/ginkgo-api#Ginkgo.GkoExecutor).

**Examples**

```julia
# Read matrix and vector from a mtx file
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
```


**External links**
- `gko::matrix::Csr<ValueType, IndexType>` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1matrix_1_1Csr.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Csr.jl#L5-L20" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoDense' href='#Ginkgo.GkoDense'><span class="jlbinding">Ginkgo.GkoDense</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
GkoDense{T} <: AbstractMatrix{T}
```


A type for representing dense matrix and vectors. Alias for `gko_matrix_dense_eltype_st` in C API.     where `eltype` is one of the DataType[Float32, Float64]. For constructing a matrix,      it is necessary to provide an [`GkoExecutor`](/reference/ginkgo-api#Ginkgo.GkoExecutor).

**Examples**

```julia
# Creating uninitialized vector of length 2, represented as a 2x1 dense matrix
julia> dim = (2,1); vec1 = GkoDense{Float32}(dim, exec)

# Passing a tuple
julia> vec2 = GkoDense{Float32}((2, 1), exec)

# Passing numbers
julia> vec3 = GkoDense{Float32}(2, 1, exec)

# Creating initialized dense vector or matrix via reading from a `.mtx` file
julia> b = GkoDense{Float32}("b.mtx", exec)

```


**External links**
- `gko::matrix::Dense<T>` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1matrix_1_1Dense.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L4-L29" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.GkoExecutor' href='#Ginkgo.GkoExecutor'><span class="jlbinding">Ginkgo.GkoExecutor</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
GkoExecutor
```


Executors are used to specify the location for the data of linear algebra objects, and to determine where the operations will be executed. In Ginkgo.jl you can select one of the types out of - `[:omp, :reference, :cuda]`

Alternatively, you can also create an executor using the [`create`](/reference/ginkgo-api#Ginkgo.create-Tuple{Symbol}) method.

**Examples**

```julia
# Creating an OpenMP executor
julia> exec = GkoExecutor(:omp)

# Creating a reference (OpenMP) executor
julia> exec = GkoExecutor(:reference)

# Creating an CUDA executor to run on Nvidia GPUs
julia> exec = GkoExecutor(:cuda)
```


**External links**
- `gko::Executor` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1Executor.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/base/Executor.jl#L4-L27" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.fill!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, G}} where {T, G}' href='#Base.fill!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, G}} where {T, G}'><span class="jlbinding">Base.fill!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.fill!(mat::GkoDense{T}, val::G) where {T, G}
```


Fill the given matrix for all matrix elements with the provided value `val`


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L102-L106" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.getindex-Union{Tuple{T}, Tuple{GkoDense{T}, Integer, Integer}} where T' href='#Base.getindex-Union{Tuple{T}, Tuple{GkoDense{T}, Integer, Integer}} where T'><span class="jlbinding">Base.getindex</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.getindex(mat::GkoDense{T}, m::Int, n::Int) where T
```


Obtain an element of the matrix, using Julia indexing


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L75-L79" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.size-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}' href='#Base.size-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}'><span class="jlbinding">Base.size</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.size(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
```


Returns the size of the sparse matrix/vector as a tuple


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Csr.jl#L45-L49" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.size-Union{Tuple{GkoDense{T}}, Tuple{T}} where T' href='#Base.size-Union{Tuple{GkoDense{T}}, Tuple{T}} where T'><span class="jlbinding">Base.size</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.size(mat::GkoDense{T}) where T
```


Returns the size of the dense matrix/vector as a tuple


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L114-L118" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.create-Tuple{Symbol}' href='#Ginkgo.create-Tuple{Symbol}'><span class="jlbinding">Ginkgo.create</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
create(executor_type::Symbol)
```


Creation of the executor of a specified executor type.

**Parameters**
- `executor_type::Symbol`: One of the executor types to create out of supported executor types [:omp, :reference, :cuda]
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/base/Executor.jl#L58-L65" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.elements-Union{Tuple{GkoDense{T}}, Tuple{T}} where T' href='#Ginkgo.elements-Union{Tuple{GkoDense{T}}, Tuple{T}} where T'><span class="jlbinding">Ginkgo.elements</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
elements(mat::GkoDense{T}) where T
```


Get number of stored elements of the matrix


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L125-L129" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.mtx_buffer_str-Union{Tuple{GkoDense{T}}, Tuple{T}} where T' href='#Ginkgo.mtx_buffer_str-Union{Tuple{GkoDense{T}}, Tuple{T}} where T'><span class="jlbinding">Ginkgo.mtx_buffer_str</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mtx_buffer_str(mat::GkoDense{T}) where T
```


Intermediate step that calls `gko::write` within C level wrapper. Allocates memory temporarily and returns a string pointer in C, then we utilize an IOBuffer to obtain a copy of the allocated cstring in Julia. In the end we deallocate the C string and return the buffered copy.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L164-L170" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.nnz-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}' href='#Ginkgo.nnz-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}'><span class="jlbinding">Ginkgo.nnz</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
nnz(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
```


Get number of stored elements of the matrix


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Csr.jl#L56-L60" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.norm1!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, GkoDense{G}}} where {T, G}' href='#Ginkgo.norm1!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, GkoDense{G}}} where {T, G}'><span class="jlbinding">Ginkgo.norm1!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
norm1!(from::GkoDense{T}, to::GkoDense{T})
```


Computes the column-wise Euclidian (L¹) norm of this matrix.

**External links**
- `void gko::matrix::Dense< ValueType >::compute_norm1` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1matrix_1_1Dense.html#a11c59175fcc040d99afe3acb39cbcb3e.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L137-L144" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.norm2!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, GkoDense{G}}} where {T, G}' href='#Ginkgo.norm2!-Union{Tuple{G}, Tuple{T}, Tuple{GkoDense{T}, GkoDense{G}}} where {T, G}'><span class="jlbinding">Ginkgo.norm2!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
norm2!(from::GkoDense{T}, to::GkoDense{T})
```


Computes the column-wise Euclidian (L²) norm of this matrix.

**External links**
- `void gko::matrix::Dense< ValueType >::compute_norm2` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1matrix_1_1Dense.html#a19b9e51fd9922bab9637e42ab7209b8c.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L150-L157" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.number' href='#Ginkgo.number'><span class="jlbinding">Ginkgo.number</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
number(val::Number, exec::GkoExecutor = EXECUTOR[])
```


Initialize a 1x1 matrix representing a number with the provided value `val`


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Dense.jl#L86-L90" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.spmm!-Union{Tuple{Ti}, Tuple{Tv}, Tuple{GkoCsr{Tv, Ti}, Vararg{GkoDense{Tv}, 4}}} where {Tv, Ti}' href='#Ginkgo.spmm!-Union{Tuple{Ti}, Tuple{Tv}, Tuple{GkoCsr{Tv, Ti}, Vararg{GkoDense{Tv}, 4}}} where {Tv, Ti}'><span class="jlbinding">Ginkgo.spmm!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
spmm!(A::GkoCsr{Tv, Ti}, α::Dense{Tv}, x::Dense{Tv}, β::Dense{Tv}, y::Dense{Tv}) where {Tv, Ti}
```


Applying to Dense matrices, computes an SpMM product. x = α_A_b + β*x.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Csr.jl#L132-L136" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.srows-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}' href='#Ginkgo.srows-Union{Tuple{GkoCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}'><span class="jlbinding">Ginkgo.srows</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
srows(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
```


Returns the number of the srow stored elements (involved warps)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/matrix/Csr.jl#L119-L123" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Ginkgo.version-Tuple{}' href='#Ginkgo.version-Tuple{}'><span class="jlbinding">Ginkgo.version</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
version()
```


Obtain the version information and the supported modules of the underlying Ginkgo library.

**External links**
- `gko::version_info::get()` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/classgko_1_1version__info.html)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/youwuyou/Ginkgo.jl/blob/58010a500c1da023098fa6e8c1a07798a3b862e0/src/Configurations.jl#L1-L8" target="_blank" rel="noreferrer">source</a></Badge>

</details>

