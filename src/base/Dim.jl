# TODO: wrap the classes
mutable struct Dim{N}
    ptr::Ptr{Union{API.gko_dim2_st, API.gko_dim3_st}}  # Assuming gko_dim2_st and gko_dim3_st are C structs

    # Constructors
    Dim{2}(first::Int, second::Int) = API.ginkgo_create_dim2(first, second)
    Dim{3}(first::Int, second::Int, third::Int) = API.ginkgo_create_dim3(first, second, third)

    # Destructors
    finalize(dim::Dim{2}) = API.ginkgo_delete_dim2(dim.ptr)
    finalize(dim::Dim{3}) = API.ginkgo_delete_dim3(dim.ptr)
end


# Equality check
==(dim1::Dim{2}, dim2::Dim{2}) = API.ginkgo_ifequal_dim2(dim1.ptr, dim2.ptr)
==(dim1::Dim{3}, dim2::Dim{3}) = API.ginkgo_ifequal_dim3(dim1.ptr, dim2.ptr)


# TODO:
# # Methods for accessing individual dimensions
# function at(dim::Dim2, index::Int)
#     ccall((:ginkgo_at_dim2, libginkgo), Cint, (gko_dim2, Cint), dim.ptr, index)
# end

# function at(dim::Dim3, index::Int)
#     ccall((:ginkgo_at_dim3, libginkgo), Cint, (gko_dim3, Cint), dim.ptr, index)
# end




