# modified from preconditioned solver
using Ginkgo

# Type alias
const (Tv, Ti) = (Float64, Int32)

# Print ginkgo library version
version()

# Creates executor for a specific backend
const exec = create(:omp)

# Read matrix and vector from mtk files
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
b = GkoDense{Tv}("data/b.mtx", exec)
x = GkoDense{Tv}("data/x0.mtx", exec)

# Create the ILU preconditioner with the deferred factory parameter
par_ilu = GkoParILUFactorization{Tv, Ti}()
ilu_preconditioner = GkoILUPreconditioner{Tv, Ti}(par_ilu)

# Use ILU preconditioner inside GMRES solver factory
ilu_gmres = GkoIterativeSolver(:gmres, A, exec; preconditioner = ilu_preconditioner, maxiter = 1000, reduction = 1.0e-7)

# Solve system
apply!(ilu_gmres, b, x)

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