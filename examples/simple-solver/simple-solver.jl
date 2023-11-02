using Ginkgo

# using Debugger

const T = Float32

# TODO: wrap Ginkgo.SparseMatrixCsr{T} - Thursday


# TODO: wrap solver - Thursday

# TODO: types to be wrapped
# using RealValueType = gko::remove_complex<double>;
# using vec = gko::matrix::Dense<double>;
# using real_vec = gko::matrix::Dense<RealValueType>;
# using mtx = gko::matrix::Csr<double, int>;
# using cg = gko::solver::Cg<double>;

# Print ginkgo library version
Ginkgo.versioninfo()

# Obtain executor with a specific backend
exec = Ginkgo.create(:omp)

# Read matrix and vector from mtk files
# auto A = gko::share(gko::read<mtx>(std::ifstream("data/A.mtx"), exec));
# auto b = gko::read<vec>(std::ifstream("data/b.mtx"), exec);
# auto x = gko::read<vec>(std::ifstream("data/x0.mtx"), exec);

# A = Ginkgo.SparseMatrixCsr{T}("data/A.mtx", exec)
b = Ginkgo.Dense{T}("data/b.mtx", exec)
x = Ginkgo.Dense{T}("data/x0.mtx", exec)

@info "Size of the vector b:" size(b)
@info "Size of the vector x:" size(x)


# TODO:
# const RealValueType reduction_factor{1e-7};
# const gko::remove_complex<double> reduction_factor{1e-7};


# auto solver_gen =
#     cg::build()
#         .with_criteria(gko::stop::Iteration::build().with_max_iters(20u),
#                        gko::stop::ResidualNorm<double>::build()
#                            .with_reduction_factor(reduction_factor))
#         .on(exec);

# Building the solver generator with selected type
# TODO: solver = Solver(exec, :CG, A, criteria)
# Solve the LSE and display results
# TODO: apply!(solver, x, b)


# Here you would proceed to solve the LSE using solver_gen
# solve!(solver_gen, A, b)
# auto solver = solver_gen->generate(A);
# solver->apply(b, x);


@info "Solution (x):"
display(x)

one     = Ginkgo.number(exec, T(1.0))
neg_one = Ginkgo.number(exec, T(-1.0))
res     = Ginkgo.number(exec, T(0.0))

# A->apply(one, x, neg_one, b);
Ginkgo.norm2!(b, res)
@info "Residual norm sqrt(r^T r):"
display(res)


# ╭─youwuyou@you in repo: ginkgo/build/examples/simple-solver on  develop [!+] took 17ms
#  ╰─λ ./simple-solver
# This is Ginkgo 1.7.0 (develop)
#     running with core module 1.7.0 (develop)
#     the reference module is  1.7.0 (develop)
#     the OpenMP    module is  1.7.0 (develop)
#     the CUDA      module is  not compiled
#     the HIP       module is  not compiled
#     the DPCPP     module is  not compiled
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
# 2.10788e-15
