# Ginkgo C Library API


## C API Design Principle

For maintaining the consistency of our code, we propose following convections [^1] when one wants to add new C language wrapper functions in `c_api.hpp` and `c_api.cpp`. 

>**Prerequisite**
>
> In Ginkgo C API, new functions should be orthogonal, each 
> serving a unique purpose without overlapping others. 
> Redundancy should be avoided, meaning new additions 
> to C API should offer distinct functionalities, not 
> replicate existing ones.

>**Compatibility to C**
>
> The `library.h` file should be kept compatible to C code 
> at a level similar to C89. Its interfaces may not 
> reference any custom data types that are only known inside of Ginkgo

>**Documentation**
>
> All changes should be clearly documented with [Doxygen]
> (https://www.doxygen.nl/) style.

>**Style Guide**
>
> Follow [recommended C style guide](https://www.doc.ic.ac.uk/lab/cplus/cstyle.html) and when commenting, only use
> [C-style comments, not C++-style](https://en.cppreference.com/w/c/comment#:~:text=single%20whitespace%20character.-,C%2Dstyle,content%20between%20%2F*%20and%20*%2F%20.).

>**Testing**
>
> Unit tests for testing newly added entries in the C API 
> should be provided


### FIXME: NOTES FOR ME 


>**Naming Conventions**
>
>Use a consistent prefix for all API functions to avoid >naming collisions. For instance, if your library is named >"Foo", your functions could be named foo_function_name.
>Use snake_case for function names and all-uppercase for >macros and defines, as this is more conventional in C.

>**Error Handling**
>
>Consider returning error codes from functions instead of >throwing exceptions (which C does not support).
>You can also provide a foo_get_last_error() function to >retrieve detailed error information after a function call.

>**Memory Management**
>
>Clearly document who is responsible for allocating and >deallocating memory. If a function returns a pointer, state >whether the caller should free it and how (e.g., with free
>() or a custom function like foo_free_data()).
>Avoid returning raw pointers. Instead, use opaque pointers >or handles, which are essentially pointers but without >exposing the underlying structure to the user.

>**Data Structures**
>
>Hide C++ classes behind opaque structs in the C API. The >users don't need to know the details, only the typedef.
>For instance, instead of exposing a std::vector, you might >provide functions like foo_vector_size(), foo_vector_get(), >etc.

>**Function Signatures**
>
>Use plain-old-data (POD) types as function arguments and >return values, avoiding C++ specific features.
>Consider using structs to pass multiple parameters to a >function or to return multiple values.

>**Object Lifecycle**
>
>For every C++ object that needs to be exposed, provide >creation and destruction functions in your C API, e.g., >foo_object_create() and foo_object_destroy().

>**Callback Mechanisms**
>
>If your library uses callbacks, expose them as function >pointers in the C API.
>Ensure that you provide a way to pass user context (usually >a void* user_data) to the callback, as C does not have >closures.



>**Versioning**
>
>Provide functions to retrieve the library's version at >runtime, e.g., foo_version().
>Consider semantic versioning to make it clear when breaking >changes are introduced.







### Correctly wrapping C++ functions

#### How are C++ types represented in Julia

TODO: talk about the macro approach (metaprogramming)

<!-- Julia offers metaprogramming capabilities where you can define macros to abstract away certain repetitive tasks. For instance, you could define a macro that automatically generates the needed cfunction code: -->

We notice the 4th argument is of type `Ptr{Cvoid}`, which represents a generic pointer in Julia, analogous to `void*` in C. In fact, when interfacing with C libraries in Julia, function pointers are typically represented using the more generic type`Ptr{Cvoid}`, allowing better callback flexibility.


TODO: [debugging with escaping problem](https://discourse.julialang.org/t/undefvarerror-x-not-defined-when-calling-a-macro-outside-of-its-module/20201)


#### How to handle C++-specific language features


#### How to exploit the power of meta programming in Julia for API


[^1]: Complying with the C API programming convention from the ["Extending the C API"](https://docs.lammps.org/Library_add.html) section of the LAMMPS library documentation.