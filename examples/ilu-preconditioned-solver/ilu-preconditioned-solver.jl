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

# // Generate incomplete factors using ParILU
# auto par_ilu_fact =
#     gko::factorization::ParIlu<ValueType, IndexType>::build().on(exec);
# // Generate concrete factorization for input matrix
# auto par_ilu = gko::share(par_ilu_fact->generate(A));

# // Generate an ILU preconditioner factory by setting lower and upper
# // triangular solver - in this case the exact triangular solves
# auto ilu_pre_factory =
#     gko::preconditioner::Ilu<gko::solver::LowerTrs<ValueType, IndexType>,
#                              gko::solver::UpperTrs<ValueType, IndexType>,
#                              false>::build()
#         .on(exec);

# // Use incomplete factors to generate ILU preconditioner
# auto ilu_preconditioner = gko::share(ilu_pre_factory->generate(par_ilu));


# # Create the ILU preconditioner
# par_ilu_fact = GkoParILUFactorization{Tv, Ti}(Ti(1000))
# ilu_preconditioner = GkoILUPreconditioner{Tv, Ti}(par_ilu_fact)

# # Use ILU preconditioner inside GMRES solver factory
# ilu_gmres = GkoLinOp(:cg, A, exec; preconditioner = ilu_preconditioner, maxiter = 1000, reduction = 1.0e-7)

# Use GMRES solver without preconditioning
gmres = GkoLinOp(:gmres, A, exec; maxiter = 1000, reduction = 1.0e-7)

# Solve system
apply!(gmres, b, x)

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


# Desired C++ results
# ╭─youwuyou@you in repo: ginkgo/build/examples/ilu-preconditioned-solver on  develop [$!] took 15ms
# ╰─λ ./ilu-preconditioned-solver 
# This is Ginkgo 1.8.0 (develop)
#    running with core module 1.8.0 (develop)
#    the reference module is  1.8.0 (develop)
#    the OpenMP    module is  1.8.0 (develop)
#    the CUDA      module is  not compiled
#    the HIP       module is  not compiled
#    the DPCPP     module is  not compiled
# Solution (x):
# %%MatrixMarket matrix array real general
# 19 1
# 0.252218
# 0.108645
# 0.0662811
# 0.0630433
# 0.0384088
# 0.0396536
# 0.0402648
# 0.0338935
# 0.0193098
# 0.0234653
# 0.0211499
# 0.0196413
# 0.0199151
# 0.0181674
# 0.0162722
# 0.0150714
# 0.0107016
# 0.0121141
# 0.0123025
# Residual norm sqrt(r^T r):
# %%MatrixMarket matrix array real general
# 1 1
# 1.46249e-08