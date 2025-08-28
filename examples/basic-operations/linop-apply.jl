using Ginkgo
using SparseArrays

# Type alias
const T = Float64

# define diagonal matrix filled with values from 1 to 10
A = spdiagm(0 => 1.0:10.0)
v_in = fill(1.0, 10)    # input vector filled with 1
v_out = zeros(10)       # output vector filled with 0
display(A)

# Type conversion is handled internally with the given executor.
exec = create(:omp)
Ginkgo.apply!(A, v_in, v_out, exec)

println("Result of applying A to v_in (stored in v_out):")
display(v_out)