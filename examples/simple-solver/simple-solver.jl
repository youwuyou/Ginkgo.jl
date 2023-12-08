using Ginkgo

# Type alias
const (Tv, Ti) = (Float32, Int32)

# Print ginkgo library version
version()

# Obtain executor with a specific backend
exec = create(:omp)

# Read matrix and vector from mtk files
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
b = GkoDense{Tv}("data/b.mtx", exec)
x = GkoDense{Tv}("data/x0.mtx", exec)

cg!(exec, x, A, b; maxiter = 20, reduction = 1.0e-7)

@info "Solution (x):"
display(x)

one     = number(exec, Tv(1.0))
neg_one = number(exec, Tv(-1.0))
res     = number(exec, Tv(0.0))

# x = one*A*b + neg_one*x
spmm!(A, one, x, neg_one, b)


norm2!(b, res)
@info "Residual norm sqrt(r^T r):"
display(res)