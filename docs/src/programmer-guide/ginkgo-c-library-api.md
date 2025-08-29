# Ginkgo C Library API


## C API Design Principle

For maintaining the consistency of our code, we propose following convections [^1] when one wants to add new C language wrapper functions in `c_api.h` and `c_api.cpp`. 

>**Prerequisite**
>
> In Ginkgo C API, new functions should be orthogonal, each 
> serving a unique purpose without overlapping others. 
> Redundancy should be avoided, meaning new additions 
> to C API should offer distinct functionalities, not 
> replicate existing ones.

>**Compatibility to C**
>
> The `c_api.h` file should be kept compatible to C code 
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


---
## Naming Conventions

Following are some naming conventions used for the Ginkgo C API.


### 1. Types

For consistency, following is a list of system independent types and their naming conventions that must be used in our Ginkgo C API.

#### System Independent Types

| C name | Standard Julia Alias | Julia Base Type | C API name |
| --- | --- | --- | --- |
| `short` | `Cshort` | `Int16` | `i16` |
| `int`,`BOOL`(C, typical) | `Cint` | `Int32` | `i32` |
| `long long` | `Clonglong` | `Int64` | `i64` |
| `float` | `Cfloat` | `Float32` | `f32` |
| `double` | `Cdouble` | `Float64` | `f64` |
| `complex float` | `ComplexF32` | `Complex{Float32}` | `cf32` |
| `complex double` | `ComplexF64` | `Complex{Float64}` | `cf64` |

### 2. Struct and pointer to struct

> If a wrapper struct is defined with `struct gko_executor_st;`, then
>the pointer to the wrapper struct is called `typedef struct gko_executor_st* gko_executor;`


### 3. Functions

>Functions are named using the pattern `gko_classname_typename_fname`,
>for more complicated member functions like `gko::matrix::Csr<float, int>` that involves two template parameters for both `ValueType` and `IndexType`, we stack the templated types one after another such as for gko::matrix::Csr<float, int>, the entry in the C API is named as `gko_matrix_csr_f32_i32_st`.


### 4. C++ Template

>In order to avoid repeating similar code for different concrete types of
>a specific templated class, we use macros to generate wrappers for concrete types
>specifically.

In the following example, we define macros to generate wrappers using selected concrete types for a templated class and (member) functions involved.


```C
// c_api.h
// Define macros to generating declarations within the header file
#define GKO_DECLARE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                \
    struct gko_array_##_name##_st;                                         \
    typedef struct gko_array_##_name##_st* gko_array_##_name;              \
    gko_array_##_name gko_array_##_name##_create(gko_executor exec_st_ptr, \
                                                 size_t size);             \
    gko_array_##_name gko_array_##_name##_create_view(                     \
        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr);          \
    void gko_array_##_name##_delete(gko_array_##_name array_st_ptr);       \
    size_t gko_array_##_name##_get_size(gko_array_##_name array_st_ptr);

// Apply the declare overload macros to declare in within the header
GKO_DECLARE_ARRAY_OVERLOAD(int16_t, int16_t, i16)
GKO_DECLARE_ARRAY_OVERLOAD(int, int, i32)
GKO_DECLARE_ARRAY_OVERLOAD(int64_t, std::int64_t, i64)
GKO_DECLARE_ARRAY_OVERLOAD(float, float, f32)
GKO_DECLARE_ARRAY_OVERLOAD(double, double, f64)
```

```C++
// c_api.cpp
// Define macros for generating implementations within the source file
#define GKO_DEFINE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                     \
    struct gko_array_##_name##_st {                                            \
        gko::array<_cpptype> arr;                                              \
    };                                                                         \
                                                                               \
    typedef gko_array_##_name##_st* gko_array_##_name;                         \
                                                                               \
    gko_array_##_name gko_array_##_name##_create(gko_executor exec_st_ptr,     \
                                                 size_t size)                  \
    {                                                                          \
        return new gko_array_##_name##_st{                                     \
            gko::array<_cpptype>{exec_st_ptr->shared_ptr, size}};              \
    }                                                                          \
                                                                               \
    gko_array_##_name gko_array_##_name##_create_view(                         \
        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr)               \
    {                                                                          \
        return new gko_array_##_name##_st{gko::make_array_view(                \
            exec_st_ptr->shared_ptr, size, static_cast<_cpptype*>(data_ptr))}; \
    }                                                                          \
                                                                               \
    void gko_array_##_name##_delete(gko_array_##_name array_st_ptr)            \
    {                                                                          \
        delete array_st_ptr;                                                   \
    }                                                                          \
                                                                               \
    size_t gko_array_##_name##_get_size(gko_array_##_name array_st_ptr)        \
    {                                                                          \
        return (*array_st_ptr).arr.get_size();                                 \
    }

// Apply the define overload macros within the source file
GKO_DEFINE_ARRAY_OVERLOAD(int16_t, int16_t, i16)
GKO_DEFINE_ARRAY_OVERLOAD(int, int, i32)
GKO_DEFINE_ARRAY_OVERLOAD(int64_t, std::int64_t, i64)
GKO_DEFINE_ARRAY_OVERLOAD(float, float, f32)
GKO_DEFINE_ARRAY_OVERLOAD(double, double, f64)
```

---
[^1]: Complying with the C API programming convention from the ["Extending the C API"](https://docs.lammps.org/Library_add.html) section of the LAMMPS library documentation.
