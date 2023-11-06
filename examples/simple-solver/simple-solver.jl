using Ginkgo

# Type alias
const (Tv, Ti) = (Float32, Int32)

# Print ginkgo library version
Ginkgo.versioninfo()

# Obtain executor with a specific backend
exec = Ginkgo.create(:omp)

# Read matrix and vector from mtk files
A = Ginkgo.SparseMatrixCsr{Tv, Ti}("data/A.mtx", exec)
b = Ginkgo.Dense{Tv}("data/b.mtx", exec)
x = Ginkgo.Dense{Tv}("data/x0.mtx", exec)

Ginkgo.cg!(exec, x, A, b; maxiter = 20, reduction = 1.0e-7)

@info "Solution (x):"
display(x)

one     = Ginkgo.number(exec, Tv(1.0))
neg_one = Ginkgo.number(exec, Tv(-1.0))
res     = Ginkgo.number(exec, Tv(0.0))

# x = one*A*b + neg_one*x
Ginkgo.spmm!(A, one, x, neg_one, b)


Ginkgo.norm2!(b, res)
@info "Residual norm sqrt(r^T r):"
display(res)
