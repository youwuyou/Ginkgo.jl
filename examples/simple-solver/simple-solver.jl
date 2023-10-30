using Ginkgo

using Debugger


# TODO: types to be wrapped
# using RealValueType = gko::remove_complex<double>;

# using vec = gko::matrix::Dense<double>;
# using real_vec = gko::matrix::Dense<RealValueType>;
# using mtx = gko::matrix::Csr<double, int>;

# using cg = gko::solver::Cg<double>;

# Print ginkgo library version
Ginkgo.get_version()

# Obtain executor with a specific backend
exec = Ginkgo.create!(:omp)



# Read matrix and vector from mtk files
# auto A = gko::share(gko::read<mtx>(std::ifstream("data/A.mtx"), exec));
# auto b = gko::read<vec>(std::ifstream("data/b.mtx"), exec);
# auto x = gko::read<vec>(std::ifstream("data/x0.mtx"), exec);

# gko::array<T> x(exec,2);
# auto A = gko::array<T>(exec,2);
A = Ginkgo.Array{Float64}(undef, exec, 2)


mtx_stream = open("data/b.mtx", "r")

# std::unique_ptr to gko::matrix::Dense<double>
# b = read(mtx_stream, exec)






# std::unique_ptr<gko::Dense<double>> b = gko::read<vec>(std::ifstream("data/b.mtx"), exec);
# std::unique_ptr<gko::Dense<double>> x = gko::read<vec>(std::ifstream("data/x0.mtx"), exec);



# TODO:
# const RealValueType reduction_factor{1e-7};
# const gko::remove_complex<double> reduction_factor{1e-7};


# auto solver_gen =
#     cg::build()
#         .with_criteria(gko::stop::Iteration::build().with_max_iters(20u),
#                        gko::stop::ResidualNorm<double>::build()
#                            .with_reduction_factor(reduction_factor))
#         .on(exec);
# auto solver = solver_gen->generate(A);

# solver->apply(b, x);

println("Solution (x):")



# write(std::cout, x);

# auto one = gko::initialize<vec>({1.0}, exec);
# auto neg_one = gko::initialize<vec>({-1.0}, exec);
# auto res = gko::initialize<real_vec>({0.0}, exec);



# A->apply(one, x, neg_one, b);
# b->compute_norm2(res);

println("Residual norm sqrt(r^T r):")


# write(std::cout, res);

