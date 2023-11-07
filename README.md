# Ginkgo.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://youwuyou.github.io/Ginkgo.jl/dev/)
[![Build Status](https://github.com/youwuyou/Ginkgo.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/youwuyou/Ginkgo.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/youwuyou/Ginkgo.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/youwuyou/Ginkgo.jl)

Ginkgo.jl is a Julia wrapper for the high-performance numerical linear algebra library [Ginkgo](https://ginkgo-project.github.io/) that aims to leverage the hardware vendor’s native programming models to implement highly tuned architecture-specific kernels. Separating the core algorithm from these architecture-specific kernels enables high performance while enhancing the readability and maintainability of the software. Seamlessly integrating Julia with Ginkgo, Ginkgo.jl interoperates with the C++ source library through a C API.

## Structure

```bash
Ginkgo.jl
├── CNAME
├── LICENSE
├── README.md
├── docs            # Documentation page with Documenter.jl
├── examples        # Example code using Ginkgo.jl
├── Manifest.toml
├── Project.toml
├── res             # For generating lower-level C API
├── src             # Contains low- and high-level Julia wrapper
└── test            # Tests
```

## Getting Started

You can install Ginkgo.jl from the Julia REPL. Press `]` to enter pkg mode, and run:

```julia
pkg> add Ginkgo
```

To start using Ginkgo.jl, simply use the package within your Julia script:

```julia
using Ginkgo
```

## Testing

For testing purposes, make sure you are in the project environment when accessing interactive shell using `julia --project`. Then execute tests within the package environment and run `test`

```shell
$ julia --project
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.9.1 (2023-06-07)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> ]
(Ginkgo) pkg>
(Ginkgo) pkg> test
```

## Features

- ✓ implemented
- ✗ not implemented
- ~ partial implementation
- n/a not applicable

||OpenMP|CUDA|HIP|DPCPP|
|:-:|:-:|:-:|:-:|:-:|
|Dense Matrix|~||||
|Sparse Matrix CSR |~||||
|Preconditioners|||||
|Solvers|~||||
|Loggers|||||
|Stopping Criteria|||||
|Utilities|||||
|IO|~||||
|...|...|...|...|...|


