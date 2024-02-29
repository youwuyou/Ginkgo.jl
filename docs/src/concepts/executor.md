# Executor

Executors are used to specify the data location of linear algebra objects, and to determine where the operations on that data shall be performed. Currently, [ginkgo](https://github.com/ginkgo-project/ginkgo) supports various backends including OpenMP, CUDA, HIP and SYCL. In `Ginkgo.jl`, we are gradually working on testing out and porting all of them.

| Executor type |  Description | Implemented in Ginkgo.jl | 
| --- | --- | --- |
| `GkoExecutor(:omp)` | specifies that the data should be stored and the associated operations executed on an OpenMP-supporting device (e.g. host CPU) | ✓ |
| `GkoExecutor(:cuda)` | specifies that the data should be stored and the operations executed on the NVIDIA GPU accelerator | ✓ |
| `GkoExecutor(:hip)` | uses the HIP library to compile code for either NVIDIA or AMD GPU accelerator | |
| `GkoExecutor(:sycl)` | uses the SYCL compiler for any SYCL supported hardware (e.g. Intel CPUs, GPU, FPGAs, ...)| |
| `GkoExecutor(:refrence)` | executes a non-optimized reference implementation, which can be used to debug the library. | ✓ |


## Usage

In `Ginkgo.jl`, we allow both passing the executor explicitly or implicitly.


!!! warning
    Please do not mix these two use cases to avoid any confusion. You shall adapt to either the explicit or the implicit usage for a single program, but not a mixed-style usage. See this [pull request](https://github.com/youwuyou/Ginkgo.jl/pull/20) in you want to know more in detail.

### 1. Explicit executor usage

Identical to the original usage as in [ginkgo](https://github.com/ginkgo-project/ginkgo), we need to provide an executor for initialization of linear algebra objects and solver routines etc. explicitly.

```julia
# Creates executor for a specific backend
const exec = create(:omp)

# Read matrix and vector from mtk files
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
b = GkoDense{Tv}("data/b.mtx", exec)
x = GkoDense{Tv}("data/x0.mtx", exec)

# Passing the executor to the CG solver
solver = GkoLinOp(:cg, A, exec; maxiter = 20, reduction = 1.0e-7)
apply!(solver, b, x)
```

!!! example
    [simple-solver-explicit-executor.jl](https://github.com/youwuyou/Ginkgo.jl/blob/main/examples/simple-solver/simple-solver-explicit-executor.jl)


### 2. Implicit executor usage

The implicit passing of the executor is enabled by using [`ScopedValues.jl`](https://github.com/vchuravy/ScopedValues.jl). We declared `EXECUTOR` to be a dynamically scoped variable in our package, and initialized it with a dummy value which just acts as a placeholder.

Within the dynamic scope, we specify the concrete executor that we refer to using the `EXECUTOR => exec` [syntax](https://github.com/youwuyou/Ginkgo.jl/pull/20#issue-2035576204).


```julia
# Creates executor for a specific backend
const exec = create(:omp)

# Specify executor to be passed for matrix creation and cg solver
with(EXECUTOR => exec) do
  # Read matrix and vector from mtk files, now omit the passing of exec
  A = GkoCsr{Float32, Int32}("data/A.mtx");
  b = GkoDense{Float32}("data/b.mtx");
  x = GkoDense{Float32}("data/x0.mtx");
  
  solver = GkoLinOp(:cg, A; maxiter = 20, reduction = 1.0e-7)
  apply!(solver, b, x)
end
```

!!! example
    [simple-solver-implicit-executor.jl](https://github.com/youwuyou/Ginkgo.jl/blob/main/examples/simple-solver/simple-solver-implicit-executor.jl)
