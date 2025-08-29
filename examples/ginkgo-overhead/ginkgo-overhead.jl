using Ginkgo
using Printf
using SparseArrays

# Type alias
const T = Float64
num_iters = 1000000

# print ginkgo library version
version()

# Creates executor for a specific backend
exec = create(:reference)

# testing solver overhead with a 1x1 system
A = spzeros(T, 1, 1); A[1, 1] = 1.0; A = GkoCsr(A, exec)
b = number(NaN, exec)
x = number(T(0.0), exec)

# time solver overhead
solver = GkoIterativeSolver(:cg, A, exec, maxiter = num_iters)
tic = time_ns()

apply!(solver, b, x)
synchronize(exec)

tac = time_ns()

total_ns = tac - tic
total_s  = total_ns / 1.0e9
avg_ns   = total_ns / num_iters

@printf("Running %d iterations of the CG solver took a total of %.5f seconds.\n", num_iters, total_s)
@printf("\tAverage library overhead:     %.2f [nanoseconds / iteration]\n", avg_ns)