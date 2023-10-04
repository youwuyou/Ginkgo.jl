# Ginkgo C Library API

### Correctly wrapping C++ functions

#### How are C++ types represented in Julia

TODO: talk about the macro approach (metaprogramming)

<!-- Julia offers metaprogramming capabilities where you can define macros to abstract away certain repetitive tasks. For instance, you could define a macro that automatically generates the needed cfunction code: -->

We notice the 4th argument is of type `Ptr{Cvoid}`, which represents a generic pointer in Julia, analogous to `void*` in C. In fact, when interfacing with C libraries in Julia, function pointers are typically represented using the more generic type`Ptr{Cvoid}`, allowing better callback flexibility.


TODO: [debugging with escaping problem](https://discourse.julialang.org/t/undefvarerror-x-not-defined-when-calling-a-macro-outside-of-its-module/20201)


#### How to handle C++-specific language features


#### How to exploit the power of meta programming in Julia for API
