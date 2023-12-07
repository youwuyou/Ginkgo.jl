var documenterSearchIndex = {"docs":
[{"location":"programmer-guide/use-ginkgo-in-julia/#Use-Ginkgo-in-Julia","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"","category":"section"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"How can we use a C++ library in our Julia code? In order to do this, we need to firstly create header file(s) that contain(s) C API. Then we can use Clang.jl to generate low-level API from it. The remaining step would be to properly wrap these low-level API methods using a higher-level API, such that users in Julia community can use our newly created Julia wrapper package as if it was a native package. Following is a workflow diagram that illustrates the whole process.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"(Image: Using C++ code in Julia)","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"In order to illustrate this workflow, we wrapped a C++ library called simpson that implements a Simpson integration scheme into a Julia package called Simpson.jl. A short tutorial is provided in the README file.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/#Understanding-how-Julia-functions-are-involved","page":"Use Ginkgo in Julia","title":"Understanding how Julia functions are involved","text":"","category":"section"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"We consider a function integrate() that performs numerical integration in our C++ library. Within the header file that contains the C API, the function declaration lies within braces of the language linkage specified with an extern \"C\" keyword. The use of this keyword disables name mangling for specified functions in C++, such that the client linker will be able to link using the C name as how you specified within the code.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"extern \"C\" {\n\ndouble integrate(const double a,\n                 const double b,\n                 const unsigned bins,\n                 double (*function)(double));\n\n\n// other methods...\n\n}","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/#1.-Analyzing-Compiled-C-Shared-Libraries","page":"Use Ginkgo in Julia","title":"1. Analyzing Compiled C++ Shared Libraries","text":"","category":"section"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"Let us suppose we have already compiled and linked our code into a shared library called libname.so. It is now essential to understand what information does the compiled shared library provides. An important tool is nm for displaying symbol table of an object, library or executable files. Using the following command nm -D libname.so, we would be able to have a peek into the shared library even without access to the source code.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"Following is an example outcome:","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"$ nm -D libname.so\n                 U __assert_fail@GLIBC_2.2.5\n                 w __cxa_finalize@GLIBC_2.2.5\n0000000000001307 T get_version\n                 w __gmon_start__\n0000000000001129 T integrate\n                 w _ITM_deregisterTMCloneTable\n                 w _ITM_registerTMCloneTable\n                 U _ZNSolsEPFRSoS_E@GLIBCXX_3.4\n                 U _ZSt21ios_base_library_initv@GLIBCXX_3.4.32\n                 U _ZSt4cout@GLIBCXX_3.4\n                 U _ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@GLIBCXX_3.4\n                 U _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc@GLIBCXX_3.4","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"As the line 0000000000001129 T integrate suggests, the function we previously defined can be referenced by the dynamic linker using the symbol name integrate at a specific address 0x1129 in the shared library. The exact same name will be needed by the dynamic linker of Julia, when the shared library will be dynamically linked ","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/#2.-Utilizing-ccall-for-Run-time-Calls-to-Shared-Library-Functions-in-Julia","page":"Use Ginkgo in Julia","title":"2. Utilizing ccall for Run-time Calls to Shared Library Functions in Julia","text":"","category":"section"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"In our Julia program, we can invoke the integrate() function that we have compiled and linked into the libname.so shared library with ccall syntax. Note that the use of the ccall is like calling a function, but it is essentially a special keyword for calling function in C-exported shared library.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"# contained in autogenerated low-level API\nfunction integrate(a, b, bins, _function)\n    ccall((:integrate, libname), Cdouble, (Cdouble, Cdouble, Cuint, Ptr{Cvoid}), a, b, bins, _function)\nend","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"The invokation of the ccall syntax specifies the shared library name and the C-exported function name that we would like to invoke. It is important to note that the function name which we specify here must be identical to what we have in the symbol table. For debugging purposes, we can also use the tool nm to look up the symbol table in order to make sure there is no name mangling.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"Then the remaining work is to provide a decent high-level wrapper function such that the users of our Ginkgo.jl package can call this function correctly. Then the JIT compiler will handle the rest.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/#How-about-performance?","page":"Use Ginkgo in Julia","title":"How about performance?","text":"","category":"section"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"Regarding the concerns if overhead would be brought by adding this layer. We cite the following information from the official Julia documentation in the section Calling C and Fortran code.","category":"page"},{"location":"programmer-guide/use-ginkgo-in-julia/","page":"Use Ginkgo in Julia","title":"Use Ginkgo in Julia","text":"The machine instructions generated by Julia's JIT are the same as a native C call would be, so the resulting overhead is the same as calling a library function from C code. Non-library function calls in both C and Julia can be inlined and thus may have even less overhead than calls to shared library functions. The point above is that the cost of actually doing foreign function call is >about the same as doing a call in either native language.","category":"page"},{"location":"performance/#Performance","page":"Performance","title":"Performance","text":"","category":"section"},{"location":"performance/","page":"Performance","title":"Performance","text":"TODO: add performance evaluation page","category":"page"},{"location":"performance/#Profiling","page":"Performance","title":"Profiling","text":"","category":"section"},{"location":"performance/","page":"Performance","title":"Performance","text":"nsys profile --stats=true --force-overwrite true -o output_profile julia --project simple-solver.jl","category":"page"},{"location":"programmer-guide/debugging/#Debugging-Tipps","page":"Debugging Tipps","title":"Debugging Tipps","text":"","category":"section"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"Debugging could be confusing especially when interoperating across different languages. Thus, we utilize the following tools for our development process that can largely reveal some hidden information.","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"gdb for low-level wrapper in C\nDebugger.jl for high-level wrapper within Julia","category":"page"},{"location":"programmer-guide/debugging/#Calling-lower-level-wrapper-functions-in-C","page":"Debugging Tipps","title":"Calling lower-level wrapper functions in C","text":"","category":"section"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"It is sometimes desirable to be able to call the lower-level functions directly in C. In order to do this, wee need to correctly link against the compiled debug mode Ginkgo dynamic library called libginkgod when using gcc.","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"Followingly is an example program where we accessed the underlying Ginkgo library through the implemented C API, resided within the Ginkgo library that we have cloned locally from Github.","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"//play_field.c\n#include \"/path/to/ginkgo/include/ginkgo/c_api.h\"\n#include <stdio.h>\n\nint main() {\n\n    ginkgo_version_get();\n\n    // create an executor\n    gko_executor exec = ginkgo_executor_omp_create();\n\n    // create an dimensional object\n    struct gko_dim2_st size = ginkgo_dim2_create(3, 4);\n\n    // create a dense matrix\n    gko_matrix_dense_f32 mat = ginkgo_matrix_dense_f32_create(exec, size);\n\n    // printf() displays the string inside quotation\n    printf(\"Number of stored elements: %zu\\n\", ginkgo_matrix_dense_f32_get_num_stored_elements(mat));\n    return 0;\n}","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"For the compilation process, this play_field.c file needs to be linked properly using the following command:","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"gcc -o play_field play_field.c -L/path/to/ginkgo/build/lib -lginkgod -Wl,-rpath=/path/to/ginkgo/build/lib -lginkgo_ompd -lginkgo_cudad -lginkgo_referenced -lginkgo_hipd -lginkgo_dpcppd -lginkgo_deviced /usr/lib/libhwloc.so /usr/lib/libmpi_cxx.so /usr/lib/libmpi.so","category":"page"},{"location":"programmer-guide/debugging/","page":"Debugging Tipps","title":"Debugging Tipps","text":"This is also helpful for verifying that the gcc compiler can properly proceed with our implemented C API.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#Ginkgo-C-Library-API","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/#C-API-Design-Principle","page":"Ginkgo C Library API","title":"C API Design Principle","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"For maintaining the consistency of our code, we propose following convections [1] when one wants to add new C language wrapper functions in c_api.h and c_api.cpp. ","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"PrerequisiteIn Ginkgo C API, new functions should be orthogonal, each  serving a unique purpose without overlapping others.  Redundancy should be avoided, meaning new additions  to C API should offer distinct functionalities, not  replicate existing ones.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"Compatibility to CThe c_api.h file should be kept compatible to C code  at a level similar to C89. Its interfaces may not  reference any custom data types that are only known inside of Ginkgo","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"DocumentationAll changes should be clearly documented with Doxygen style.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"Style GuideFollow recommended C style guide and when commenting, only use C-style comments, not C++-style.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"TestingUnit tests for testing newly added entries in the C API  should be provided","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#Naming-Conventions","page":"Ginkgo C Library API","title":"Naming Conventions","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"Following are some naming conventions used for the Ginkgo C API.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#1.-Types","page":"Ginkgo C Library API","title":"1. Types","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"For consistency, following is a list of system independent types and their naming conventions that must be used in our Ginkgo C API.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#System-Independent-Types","page":"Ginkgo C Library API","title":"System Independent Types","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"C name Standard Julia Alias Julia Base Type C API name\nshort Cshort Int16 i16\nint,BOOL(C, typical) Cint Int32 i32\nlong long Clonglong Int64 i64\nfloat Cfloat Float32 f32\ndouble Cdouble Float64 f64\ncomplex float ComplexF32 Complex{Float32} cf32\ncomplex double ComplexF64 Complex{Float64} cf64","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#2.-Struct-and-pointer-to-struct","page":"Ginkgo C Library API","title":"2. Struct and pointer to struct","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"If a wrapper struct is defined with struct gko_executor_st;, then the pointer to the wrapper struct is called typedef struct gko_executor_st* gko_executor;","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#3.-Functions","page":"Ginkgo C Library API","title":"3. Functions","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"Functions are named using the pattern ginkgo_classname_typename_fname, for more complicated member functions like gko::matrix::Csr<float, int> that involves two template parameters for both ValueType and IndexType, we stack the templated types one after another such as for gko::matrix::Csr<float, int>, the entry in the C API is named as gko_matrix_csr_f32_i32_st.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/#4.-C-Template","page":"Ginkgo C Library API","title":"4. C++ Template","text":"","category":"section"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"In order to avoid repeating similar code for different concrete types of a specific templated class, we use macros to generate wrappers for concrete types specifically.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"In the following example, we define macros to generate wrappers using selected concrete types for a templated class and (member) functions involved.","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"// c_api.h\n\n\n// Define macros to generating declarations within the header file\n#define DECLARE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                       \\\n    struct gko_array_##_name##_st;                                            \\\n    typedef struct gko_array_##_name##_st* gko_array_##_name;                 \\\n    gko_array_##_name ginkgo_array_##_name##_create(gko_executor exec_st_ptr, \\\n                                                    size_t size);             \\\n    gko_array_##_name ginkgo_array_##_name##_create_view(                     \\\n        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr);             \\\n    void ginkgo_array_##_name##_delete(gko_array_##_name array_st_ptr);       \\\n    size_t ginkgo_array_##_name##_get_num_elems(gko_array_##_name array_st_ptr);\n\n// Define macros for generating implementations within the source file\n#define DEFINE_ARRAY_OVERLOAD(_ctype, _cpptype, _name)                         \\\n    struct gko_array_##_name##_st {                                            \\\n        gko::array<_cpptype> arr;                                              \\\n    };                                                                         \\\n                                                                               \\\n    typedef gko_array_##_name##_st* gko_array_##_name;                         \\\n                                                                               \\\n    gko_array_##_name ginkgo_array_##_name##_create(gko_executor exec_st_ptr,  \\\n                                                    size_t size)               \\\n    {                                                                          \\\n        return new gko_array_##_name##_st{                                     \\\n            gko::array<_cpptype>{exec_st_ptr->shared_ptr, size}};              \\\n    }                                                                          \\\n                                                                               \\\n    gko_array_##_name ginkgo_array_##_name##_create_view(                      \\\n        gko_executor exec_st_ptr, size_t size, _ctype* data_ptr)               \\\n    {                                                                          \\\n        return new gko_array_##_name##_st{gko::make_array_view(                \\\n            exec_st_ptr->shared_ptr, size, static_cast<_cpptype*>(data_ptr))}; \\\n    }                                                                          \\\n                                                                               \\\n    void ginkgo_array_##_name##_delete(gko_array_##_name array_st_ptr)         \\\n    {                                                                          \\\n        delete array_st_ptr;                                                   \\\n    }                                                                          \\\n                                                                               \\\n    size_t ginkgo_array_##_name##_get_num_elems(                               \\\n        gko_array_##_name array_st_ptr)                                        \\\n    {                                                                          \\\n        return (*array_st_ptr).arr.get_num_elems();                            \\\n    }\n\n\n// Apply the declare overload macros to declare in within the header\nDECLARE_ARRAY_OVERLOAD(short, short, i16);\nDECLARE_ARRAY_OVERLOAD(int, int, i32);\nDECLARE_ARRAY_OVERLOAD(long long, long long, i64);\nDECLARE_ARRAY_OVERLOAD(float, float, f32);\nDECLARE_ARRAY_OVERLOAD(double, double, f64);\nDECLARE_ARRAY_OVERLOAD(float complex, std::complex<float>, cf32);\nDECLARE_ARRAY_OVERLOAD(double complex, std::complex<double>, cf64);","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"// c_api.cpp\n// Apply the define overload macros to declare in within the header\nDEFINE_ARRAY_OVERLOAD(short, short, i16);\nDEFINE_ARRAY_OVERLOAD(int, int, i32);\nDEFINE_ARRAY_OVERLOAD(long long, long long, i64);\nDEFINE_ARRAY_OVERLOAD(float, float, f32);\nDEFINE_ARRAY_OVERLOAD(double, double, f64);\nDEFINE_ARRAY_OVERLOAD(float _Complex, std::complex<float>, cf32);\nDEFINE_ARRAY_OVERLOAD(double _Complex, std::complex<double>, cf64);","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"","category":"page"},{"location":"programmer-guide/ginkgo-c-library-api/","page":"Ginkgo C Library API","title":"Ginkgo C Library API","text":"[1]: Complying with the C API programming convention from the \"Extending the C API\" section of the LAMMPS library documentation.","category":"page"},{"location":"programmer-guide/CONTRIBUTING/#Contributing","page":"Contributing","title":"Contributing","text":"","category":"section"},{"location":"programmer-guide/CONTRIBUTING/","page":"Contributing","title":"Contributing","text":"We are glad that you are interested in contributing to Ginkgo. Please have a look at Julia contributing guidelines, Ginkgo contributing guidelines and file us a GitHub issue before proposing a pull request.","category":"page"},{"location":"reindex/#Index","page":"Index","title":"Index","text":"","category":"section"},{"location":"reindex/","page":"Index","title":"Index","text":"","category":"page"},{"location":"reference/low-level-api/#Low-level-API","page":"Low-level API","title":"Low-level API","text":"","category":"section"},{"location":"reference/low-level-api/","page":"Low-level API","title":"Low-level API","text":"The Ginkgo.API submodule provides a low-level interface which closely matches the Ginkgo C API. While these functions are not intended for general usage, they are useful for calling Ginkgo routines not yet available in Ginkgo.jl main interface, and is the basis for the high-level wrappers. For illustrative purpose, we use a example api.jl here, yet to be replaced.","category":"page"},{"location":"reference/low-level-api/","page":"Low-level API","title":"Low-level API","text":"Modules = [Ginkgo.API]\nOrder = [:function, :type]","category":"page"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_dim2_cols_get-Tuple{Any}","page":"Low-level API","title":"Ginkgo.API.ginkgo_dim2_cols_get","text":"ginkgo_dim2_cols_get(dim)\n\nObtains the value of the second element of a gko::dim<2> type\n\nParameters\n\ndim: An object of gko_dim2_st type\n\nReturns\n\nsize_t Second dimension\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_dim2_create-Tuple{Any, Any}","page":"Low-level API","title":"Ginkgo.API.ginkgo_dim2_create","text":"ginkgo_dim2_create(rows, cols)\n\nAllocates memory for a C-based reimplementation of the gko::dim<2> type\n\nParameters\n\nrows: First dimension\ncols: Second dimension\n\nReturns\n\ngko_dim2_st C struct that contains members of the gko::dim<2> type\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_dim2_rows_get-Tuple{Any}","page":"Low-level API","title":"Ginkgo.API.ginkgo_dim2_rows_get","text":"ginkgo_dim2_rows_get(dim)\n\nObtains the value of the first element of a gko::dim<2> type\n\nParameters\n\ndim: An object of gko_dim2_st type\n\nReturns\n\nsize_t First dimension\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_executor_delete-Tuple{Any}","page":"Low-level API","title":"Ginkgo.API.ginkgo_executor_delete","text":"ginkgo_executor_delete(exec_st_ptr)\n\nDeallocates memory for an executor on targeted device.\n\nParameters\n\nexec_st_ptr: Raw pointer to the shared pointer of the executor to be deleted\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_matrix_csr_f32_i32_apply-NTuple{5, Any}","page":"Low-level API","title":"Ginkgo.API.ginkgo_matrix_csr_f32_i32_apply","text":"ginkgo_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)\n\nPerforms an SpMM product\n\nParameters\n\nmat_st_ptr:\nalpha:\nx:\nbeta:\ny:\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.ginkgo_version_get-Tuple{}","page":"Low-level API","title":"Ginkgo.API.ginkgo_version_get","text":"ginkgo_version_get()\n\nThis function is a wrapper for obtaining the version of the ginkgo library\n\n\n\n\n\n","category":"method"},{"location":"reference/low-level-api/#Ginkgo.API.gko_dim2_st","page":"Low-level API","title":"Ginkgo.API.gko_dim2_st","text":"gko_dim2_st\n\nStruct implements the gko::dim<2> type\n\n\n\n\n\n","category":"type"},{"location":"reference/low-level-api/#Ginkgo.API.gko_executor","page":"Low-level API","title":"Ginkgo.API.gko_executor","text":"Type of the pointer to the wrapped gko_executor_st struct\n\n\n\n\n\n","category":"type"},{"location":"reference/low-level-api/#Ginkgo.API.gko_executor_st","page":"Low-level API","title":"Ginkgo.API.gko_executor_st","text":"Struct containing the shared pointer to a ginkgo executor\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = Ginkgo","category":"page"},{"location":"#Ginkgo.jl","page":"Home","title":"Ginkgo.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Ginkgo.jl is a Julia wrapper for the high-performance numerical linear algebra library Ginkgo that aims to leverage the hardware vendor’s native programming models to implement highly tuned architecture-specific kernels. Separating the core algorithm from these architecture- specific kernels enables high performance while enhancing the readability and maintainability of the software. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the main page of the user documentation for Ginkgo.jl.","category":"page"},{"location":"reference/ginkgo-api/#Ginkgo.jl-API","page":"Ginkgo.jl API","title":"Ginkgo.jl API","text":"","category":"section"},{"location":"reference/ginkgo-api/","page":"Ginkgo.jl API","title":"Ginkgo.jl API","text":"CurrentModule = Ginkgo","category":"page"},{"location":"reference/ginkgo-api/","page":"Ginkgo.jl API","title":"Ginkgo.jl API","text":"Modules = [Ginkgo]","category":"page"},{"location":"reference/ginkgo-api/#Ginkgo.Dense","page":"Ginkgo.jl API","title":"Ginkgo.Dense","text":"Dense{T} <: AbstractMatrix{T}\n\nA type for representing dense matrix and vectors. Alias for gko_matrix_dense_eltype_st in C API.     where eltype is one of the DataType[Float32, Float64]. For constructing a matrix, it is     necessary to provide an executor using the create method.\n\nExamples\n\n# Creating uninitialized vector of length 2, represented as a 2x1 dense matrix\njulia> dim = Ginkgo.Dim{2}(2,1); vec1 = Ginkgo.Dense{Float32}(exec, dim)\n\n# Passing a tuple\njulia> vec2 = Ginkgo.Dense{Float32}(exec, (2, 1));\n\n# Passing numbers\njulia> vec3 = Ginkgo.Dense{Float32}(exec, 2, 1);\n\n# Creating uninitialized dense square matrix\njulia> square_mat = Ginkgo.Dense{Float32}(exec, 2);\n\n# Creating initialized dense vector or matrix via reading from a `.mtx` file\njulia> b = Ginkgo.Dense{Float32}(\"b.mtx\", exec);\n\n\nExternal links\n\ngko::matrix::Dense<T> man page Ginkgo\n\n\n\n\n\n","category":"type"},{"location":"reference/ginkgo-api/#Ginkgo.Dim","page":"Ginkgo.jl API","title":"Ginkgo.Dim","text":"Dim{N}\n\nAbstract type for creating gko::dim<N> like objects\n\nImplementation of operations at the Julia side\n\nExternal links\n\ngko::dim<N> man page Ginkgo\n\n\n\n\n\n","category":"type"},{"location":"reference/ginkgo-api/#Ginkgo.Dim2","page":"Ginkgo.jl API","title":"Ginkgo.Dim2","text":"Dim2 <: Dim{2}\n\nA type for representing the dimensions of an object. Alias for gko_dim2_st in C API.\n\nExamples\n\n# Creating uninitialized dimensional object\njulia> Ginkgo.Dim{2}()\n(0, 0)\n\n# Creating initialized dimensional object for identical row and column numbers\njulia> Ginkgo.Dim{2}(3)\n(3, 3)\n\n# Creaing initialized dimensional object of specified row and column numbers\njulia> Ginkgo.Dim{2}(6,9)\n(6, 9)\n\n\n\n\n\n","category":"type"},{"location":"reference/ginkgo-api/#Ginkgo.SparseMatrixCsr","page":"Ginkgo.jl API","title":"Ginkgo.SparseMatrixCsr","text":"SparseMatrixCsr{Tv, Ti} <: AbstractMatrix{Tv, Ti}\n\nA type for representing sparse matrix and vectors in CSR format. Alias for gko_matrix_csr_eltype_indextype_st in C API.     where eltype is one of the DataType[Float32, Float64] and indextype is one of the DataType[Int16, Int32, Int64].     For constructing a matrix, it is necessary to provide an executor using the create method.\n\nExamples\n\n\n\nExternal links\n\ngko::matrix::Csr<ValueType, IndexType> man page Ginkgo\n\n\n\n\n\n","category":"type"},{"location":"reference/ginkgo-api/#Base.fill!-Union{Tuple{G}, Tuple{T}, Tuple{Ginkgo.Dense{T}, G}} where {T, G}","page":"Ginkgo.jl API","title":"Base.fill!","text":"Base.fill!(mat::Dense{T}, val::G) where {T, G}\n\nFill the given matrix for all matrix elements with the provided value val\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Base.getindex-Union{Tuple{T}, Tuple{Ginkgo.Dense{T}, Integer, Integer}} where T","page":"Ginkgo.jl API","title":"Base.getindex","text":"Base.getindex(mat::Dense{T}, m::Int, n::Int) where T\n\nObtain an element of the matrix, using Julia indexing\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Base.size-Union{Tuple{Ginkgo.Dense{T}}, Tuple{T}} where T","page":"Ginkgo.jl API","title":"Base.size","text":"Base.size(mat::Dense{T}) where T\n\nReturns the size of the dense matrix/vector as a tuple\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Base.size-Union{Tuple{Ginkgo.SparseMatrixCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}","page":"Ginkgo.jl API","title":"Base.size","text":"Base.size(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}\n\nReturns the size of the sparse matrix/vector as a tuple\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.create-Tuple{Symbol}","page":"Ginkgo.jl API","title":"Ginkgo.create","text":"create(executor_type::Symbol)\n\nCreation of the executor of a specified executor type.\n\nParameters\n\nexecutor_type::Symbol: One of the executor types to create out of supported executor types [:omp, :reference, :cuda]\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.elements-Union{Tuple{Ginkgo.Dense{T}}, Tuple{T}} where T","page":"Ginkgo.jl API","title":"Ginkgo.elements","text":"elements(mat::Dense{T}) where T\n\nGet number of stored elements of the matrix\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.mtx_buffer_str-Union{Tuple{Ginkgo.Dense{T}}, Tuple{T}} where T","page":"Ginkgo.jl API","title":"Ginkgo.mtx_buffer_str","text":"mtxbufferstr(mat::Dense{T}) where T\n\nIntermediate step that calls gko::write within C level wrapper. Allocates memory temporarily and returns a string pointer in C, then we utilize an IOBuffer to obtain a copy of the allocated cstring in Julia. In the end we deallocate the C string and return the buffered copy.\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.nnz-Union{Tuple{Ginkgo.SparseMatrixCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}","page":"Ginkgo.jl API","title":"Ginkgo.nnz","text":"nnz(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}\n\nGet number of stored elements of the matrix\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.norm1!-Union{Tuple{G}, Tuple{T}, Tuple{Ginkgo.Dense{T}, Ginkgo.Dense{G}}} where {T, G}","page":"Ginkgo.jl API","title":"Ginkgo.norm1!","text":"norm1!(from::Dense{T}, to::Dense{T})\n\nComputes the column-wise Euclidian (L¹) norm of this matrix.\n\nExternal links\n\nvoid gko::matrix::Dense< ValueType >::compute_norm1 man page Ginkgo\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.norm2!-Union{Tuple{G}, Tuple{T}, Tuple{Ginkgo.Dense{T}, Ginkgo.Dense{G}}} where {T, G}","page":"Ginkgo.jl API","title":"Ginkgo.norm2!","text":"norm2!(from::Dense{T}, to::Dense{T})\n\nComputes the column-wise Euclidian (L²) norm of this matrix.\n\nExternal links\n\nvoid gko::matrix::Dense< ValueType >::compute_norm2 man page Ginkgo\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.number-Tuple{Any, Number}","page":"Ginkgo.jl API","title":"Ginkgo.number","text":"number(exec, val::Number)\n\nInitialize a 1x1 matrix representing a number with the provided value val\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.spmm!-Union{Tuple{Ti}, Tuple{Tv}, Tuple{Ginkgo.SparseMatrixCsr{Tv, Ti}, Vararg{Ginkgo.Dense{Tv}, 4}}} where {Tv, Ti}","page":"Ginkgo.jl API","title":"Ginkgo.spmm!","text":"spmm!(A::SparseMatrixCsr{Tv, Ti}, α::Dense{Tv}, x::Dense{Tv}, β::Dense{Tv}, y::Dense{Tv}) where {Tv, Ti}\n\nx = α*A*b + β*x\n\nApplying to Dense matrices, computes an SpMM product.\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.srows-Union{Tuple{Ginkgo.SparseMatrixCsr{Tv, Ti}}, Tuple{Ti}, Tuple{Tv}} where {Tv, Ti}","page":"Ginkgo.jl API","title":"Ginkgo.srows","text":"srows(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}\n\nReturns the number of the srow stored elements (involved warps)\n\n\n\n\n\n","category":"method"},{"location":"reference/ginkgo-api/#Ginkgo.versioninfo-Tuple{}","page":"Ginkgo.jl API","title":"Ginkgo.versioninfo","text":"versioninfo()\n\nObtain the version information and the supported modules of the underlying Ginkgo library.\n\n\n\n\n\n","category":"method"}]
}
