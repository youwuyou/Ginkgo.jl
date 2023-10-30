# gko::matrix::Dense<double>


# Issue: problematic to pass std::initializer_list
# eg. auto a = {1.0, 2.0};
# no conversion from other types to intializer_list possible,
# values need to be known at compile time => not possible for usage in Julia
# auto m = gko::initialize<gko::matrix::Dense<TypeParam>>({1.0, 2.0}, this->exec);

# Approach: using create for each matrix instead?
# auto m2 = gko::matrix::Dense<TypeParam>::create(this->exec, gko::dim<2>{2, 1}, 2);
# auto original_data = m2->get_values();


# TYPED_TEST(Dense, ComputesNorm2)
# {
#     using Mtx = typename TestFixture::Mtx;
#     using T = typename TestFixture::value_type;
#     using T_nc = gko::remove_complex<T>;
#     using NormVector = gko::matrix::Dense<T_nc>;
#     auto mtx(gko::initialize<Mtx>(
#         {I<T>{1.0, 0.0}, I<T>{2.0, 3.0}, I<T>{2.0, 4.0}}, this->exec));
#     auto result = NormVector::create(this->exec, gko::dim<2>{1, 2});

#     mtx->compute_norm2(result);

#     EXPECT_EQ(result->at(0, 0), T_nc{3.0});
#     EXPECT_EQ(result->at(0, 1), T_nc{5.0});
# }





# TODO: wrap these three functions for initializing Dense matrix!
# protected:
#     /**
#      * Creates an uninitialized Dense matrix of the specified size.
#      *
#      * @param exec  Executor associated to the matrix
#      * @param size  size of the matrix
#      */
#     Dense(std::shared_ptr<const Executor> exec, const dim<2>& size = dim<2>{})
#         : Dense(std::move(exec), size, size[1])
#     {}

#     /**
#      * Creates an uninitialized Dense matrix of the specified size.
#      *
#      * @param exec  Executor associated to the matrix
#      * @param size  size of the matrix
#      * @param stride  stride of the rows (i.e. offset between the first
#      *                  elements of two consecutive rows, expressed as the
#      *                  number of matrix elements)
#      */
#     Dense(std::shared_ptr<const Executor> exec, const dim<2>& size,
#           size_type stride)
#         : EnableLinOp<Dense>(exec, size),
#           values_(exec, size[0] * stride),
#           stride_(stride)
#     {}

#     /**
#      * Creates a Dense matrix from an already allocated (and initialized) array.
#      *
#      * @tparam ValuesArray  type of array of values
#      *
#      * @param exec  Executor associated to the matrix
#      * @param size  size of the matrix
#      * @param values  array of matrix values
#      * @param stride  stride of the rows (i.e. offset between the first
#      *                  elements of two consecutive rows, expressed as the
#      *                  number of matrix elements)
#      *
#      * @note If `values` is not an rvalue, not an array of ValueType, or is on
#      *       the wrong executor, an internal copy will be created, and the
#      *       original array data will not be used in the matrix.
#      */
#     template <typename ValuesArray>
#     Dense(std::shared_ptr<const Executor> exec, const dim<2>& size,
#           ValuesArray&& values, size_type stride)
#         : EnableLinOp<Dense>(exec, size),
#           values_{exec, std::forward<ValuesArray>(values)},
#           stride_{stride}
#     {
#         if (size[0] > 0 && size[1] > 0) {
#             GKO_ENSURE_IN_BOUNDS((size[0] - 1) * stride + size[1] - 1,
#                                  values_.get_num_elems());
#         }
#     }





# TODO:
# This can be realize by setting a default fot the Real abstract type
# using real_vec = gko::matrix::Dense<RealValueType>;