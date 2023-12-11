using Ginkgo

# Type alias
const (Tv, Ti) = (Float32, Int32)

# Print ginkgo library version
version()

# Obtain executor with a specific backend
const exec = create(:omp)

# Specify executor to be passed for matrix creation including CSR, Dense and "number" and cg solver
@with EXECUTOR => exec begin
  # Read matrix and vector from mtk files, now omit the passing of exec
  A = GkoCsr{Tv, Ti}("data/A.mtx");
  b = GkoDense{Tv}("data/b.mtx");
  x = GkoDense{Tv}("data/x0.mtx");
  
  cg!(x, A, b; maxiter = 20, reduction = 1.0e-7)

  @info "Solution (x):"
  display(x)
  
  one     = number(Tv(1.0))
  neg_one = number(Tv(-1.0))
  res     = number(Tv(0.0))

  # x = one*A*b + neg_one*x
  spmm!(A, one, x, neg_one, b)
  
  norm2!(b, res)
  @info "Residual norm sqrt(r^T r):"
  display(res)
end
