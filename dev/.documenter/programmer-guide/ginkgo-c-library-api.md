
# Ginkgo C Library API {#Ginkgo-C-Library-API}

## C API Design Principle {#C-API-Design-Principle}

For maintaining the consistency of our code, we propose following convections [^1] when one wants to add new C language wrapper functions in `c_api.h` and `c_api.cpp`. 
> 
> **Prerequisite**
> 
> In Ginkgo C API, new functions should be orthogonal, each  serving a unique purpose without overlapping others.  Redundancy should be avoided, meaning new additions  to C API should offer distinct functionalities, not  replicate existing ones.
> 

> 
> **Compatibility to C**
> 
> The `c_api.h` file should be kept compatible to C code  at a level similar to C89. Its interfaces may not  reference any custom data types that are only known inside of Ginkgo
> 

> 
> **Documentation**
> 
> All changes should be clearly documented with [Doxygen](https://www.doxygen.nl/) style.
> 

> 
> **Style Guide**
> 
> Follow [recommended C style guide](https://www.doc.ic.ac.uk/lab/cplus/cstyle.html) and when commenting, only use [C-style comments, not C++-style](https://en.cppreference.com/w/c/comment#:~:text=single%20whitespace%20character.-,C%2Dstyle,content%20between%20%2F*%20and%20*%2F%20.).
> 

> 
> **Testing**
> 
> Unit tests for testing newly added entries in the C API  should be provided
> 



---


## Naming Conventions {#Naming-Conventions}

Following are some naming conventions used for the Ginkgo C API.

### 1. Types {#1.-Types}

For consistency, following is a list of system independent types and their naming conventions that must be used in our Ginkgo C API.

#### System Independent Types {#System-Independent-Types}

|                   C name | Standard Julia Alias |    Julia Base Type | C API name |
| ------------------------:| --------------------:| ------------------:| ----------:|
|                  `short` |             `Cshort` |            `Int16` |      `i16` |
| `int`,`BOOL`(C, typical) |               `Cint` |            `Int32` |      `i32` |
|              `long long` |          `Clonglong` |            `Int64` |      `i64` |
|                  `float` |             `Cfloat` |          `Float32` |      `f32` |
|                 `double` |            `Cdouble` |          `Float64` |      `f64` |
|          `complex float` |         `ComplexF32` | `Complex{Float32}` |     `cf32` |
|         `complex double` |         `ComplexF64` | `Complex{Float64}` |     `cf64` |


### 2. Struct and pointer to struct {#2.-Struct-and-pointer-to-struct}
> 
> If a wrapper struct is defined with `struct gko_executor_st;`, then the pointer to the wrapper struct is called `typedef struct gko_executor_st* gko_executor;`
> 


### 3. Functions {#3.-Functions}
> 
> Functions are named using the pattern `ginkgo_classname_typename_fname`, for more complicated member functions like `gko::matrix::Csr<float, int>` that involves two template parameters for both `ValueType` and `IndexType`, we stack the templated types one after another such as for gko::matrix::Csr&lt;float, int&gt;, the entry in the C API is named as `gko_matrix_csr_f32_i32_st`.
> 


### 4. C++ Template {#4.-C-Template}
> 
> In order to avoid repeating similar code for different concrete types of a specific templated class, we use macros to generate wrappers for concrete types specifically.
> 


In the following example, we define macros to generate wrappers using selected concrete types for a templated class and (member) functions involved.

```C
// c_api.h


// Define macros to generating declarations within the header file
#define DECLARE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                       \
    struct gko_array_##_name##_st;                                            \
    typedef struct gko_array_##_name##_st* gko_array_##_name;                 \
    gko_array_##_name ginkgo_array_##_name##_create(gko_executor exec_st_ptr, \
                                                    size_t size);             \
    gko_array_##_name ginkgo_array_##_name##_create_view(                     \
        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr);             \
    void ginkgo_array_##_name##_delete(gko_array_##_name array_st_ptr);       \
    size_t ginkgo_array_##_name##_get_num_elems(gko_array_##_name array_st_ptr);

// Define macros for generating implementations within the source file
#define DEFINE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                         \
    struct gko_array_##_name##_st {                                            \
        gko::array<_cpptype> arr;                                              \
    };                                                                         \
                                                                               \
    typedef gko_array_##_name##_st* gko_array_##_name;                         \
                                                                               \
    gko_array_##_name ginkgo_array_##_name##_create(gko_executor exec_st_ptr,  \
                                                    size_t size)               \
    {                                                                          \
        return new gko_array_##_name##_st{                                     \
            gko::array<_cpptype>{exec_st_ptr->shared_ptr, size}};              \
    }                                                                          \
                                                                               \
    gko_array_##_name ginkgo_array_##_name##_create_view(                      \
        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr)               \
    {                                                                          \
        return new gko_array_##_name##_st{gko::make_array_view(                \
            exec_st_ptr->shared_ptr, size, static_cast<_cpptype*>(data_ptr))}; \
    }                                                                          \
                                                                               \
    void ginkgo_array_##_name##_delete(gko_array_##_name array_st_ptr)         \
    {                                                                          \
        delete array_st_ptr;                                                   \
    }                                                                          \
                                                                               \
    size_t ginkgo_array_##_name##_get_num_elems(                               \
        gko_array_##_name array_st_ptr)                                        \
    {                                                                          \
        return (*array_st_ptr).arr.get_num_elems();                            \
    }


// Apply the declare overload macros to declare in within the header
DECLARE_ARRAY_OVERLOAD(short, short, i16);
DECLARE_ARRAY_OVERLOAD(int, int, i32);
DECLARE_ARRAY_OVERLOAD(long long, long long, i64);
DECLARE_ARRAY_OVERLOAD(float, float, f32);
DECLARE_ARRAY_OVERLOAD(double, double, f64);
DECLARE_ARRAY_OVERLOAD(float complex, std::complex<float>, cf32);
DECLARE_ARRAY_OVERLOAD(double complex, std::complex<double>, cf64);
```


```C++
// c_api.cpp
// Apply the define overload macros to declare in within the header
DEFINE_ARRAY_OVERLOAD(short, short, i16);
DEFINE_ARRAY_OVERLOAD(int, int, i32);
DEFINE_ARRAY_OVERLOAD(long long, long long, i64);
DEFINE_ARRAY_OVERLOAD(float, float, f32);
DEFINE_ARRAY_OVERLOAD(double, double, f64);
DEFINE_ARRAY_OVERLOAD(float _Complex, std::complex<float>, cf32);
DEFINE_ARRAY_OVERLOAD(double _Complex, std::complex<double>, cf64);
```



---


[^1]: Complying with the C API programming convention from the [&quot;Extending the C API&quot;](https://docs.lammps.org/Library_add.html) section of the LAMMPS library documentation.

