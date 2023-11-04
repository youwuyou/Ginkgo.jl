# Debugging Tipps

Debugging could be confusing especially when interoperating across different languages. Thus, we utilize the following tools for our development process that can largely reveal some hidden information.

- `gdb` for low-level wrapper in C
- `Debugger.jl` for high-level wrapper within Julia


## Calling lower-level wrapper functions in C

It is sometimes desirable to be able to call the lower-level functions
directly in C. In order to do this, wee need to correctly link against the compiled debug mode Ginkgo dynamic library called `libginkgod` when using `gcc`.

Followingly is an example program where we accessed the underlying Ginkgo library through the implemented C API, resided within the [Ginkgo library](https://github.com/ginkgo-project/ginkgo) that we have cloned locally from Github.


```C
//play_field.c
#include "/path/to/ginkgo/include/ginkgo/c_api.h"
#include <stdio.h>

int main() {

    ginkgo_version_get();

    // create an executor
    gko_executor exec = ginkgo_executor_omp_create();

    // create an dimensional object
    struct gko_dim2_st size = ginkgo_dim2_create(3, 4);

    // create a dense matrix
    gko_matrix_dense_f32 mat = ginkgo_matrix_dense_f32_create(exec, size);

    // printf() displays the string inside quotation
    printf("Number of stored elements: %zu\n", ginkgo_matrix_dense_f32_get_num_stored_elements(mat));
    return 0;
}
```


For the compilation process, this `play_field.c` file needs to be linked properly using the following command:

```bash
gcc -o play_field play_field.c -L/path/to/ginkgo/build/lib -lginkgod -Wl,-rpath=/path/to/ginkgo/build/lib -lginkgo_ompd -lginkgo_cudad -lginkgo_referenced -lginkgo_hipd -lginkgo_dpcppd -lginkgo_deviced /usr/lib/libhwloc.so /usr/lib/libmpi_cxx.so /usr/lib/libmpi.so
```

This is also helpful for verifying that the `gcc` compiler can properly
proceed with our implemented C API.