#include "/home/youwuyou/workspace/HS23/ICL_Tennessee/forked_ginkgo/ginkgo/include/ginkgo/c_api.h"
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