# modified from preconditioned solver
using Ginkgo

# Type alias
const (Tv, Ti) = (Float64, Int32)

# Print ginkgo library version
version()

# Creates executor for a specific backend
exec = create(:omp)

# Read matrix and vector from mtk files
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
b = GkoDense{Tv}("data/b.mtx", exec)
x = GkoDense{Tv}("data/x0.mtx", exec)

# Use GMRES solver without preconditioning
gmres = GkoIterativeSolver(:gmres, A, exec; maxiter = 1000, reduction = 1.0e-7)

# Solve system
apply!(gmres, b, x)

@info "Solution (x):"
display(x)

one     = number(Tv(1.0), exec)
neg_one = number(Tv(-1.0), exec)
res     = number(Tv(0.0), exec)

# x = one*A*b + neg_one*x
apply!(A, one, x, neg_one, b)

norm2!(b, res)
@info "Residual norm sqrt(r^T r):"
display(res)