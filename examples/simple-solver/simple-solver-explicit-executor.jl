using Ginkgo

# Type alias
const (Tv, Ti) = (Float32, Int32)

# Print ginkgo library version
version()

# Obtain executor with a specific backend
const exec = create(:omp)

# Read matrix and vector from mtk files
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
b = GkoDense{Tv}("data/b.mtx", exec)
x = GkoDense{Tv}("data/x0.mtx", exec)

cg!(x, A, b, exec; maxiter = 20, reduction = 1.0e-7)

@info "Solution (x):"
display(x)

one     = number(Tv(1.0), exec)
neg_one = number(Tv(-1.0), exec)
res     = number(Tv(0.0), exec)

# x = one*A*b + neg_one*x
spmm!(A, one, x, neg_one, b)


norm2!(b, res)
@info "Residual norm sqrt(r^T r):"
display(res)