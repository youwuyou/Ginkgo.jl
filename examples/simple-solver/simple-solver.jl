using Ginkgo

using Debugger


hidden = true



# TODO: 
# using RealValueType = gko::remove_complex<double>;
# using vec = gko::matrix::Dense<double>;
# using real_vec = gko::matrix::Dense<RealValueType>;
# using mtx = gko::matrix::Csr<double, int>;
# using cg = gko::solver::Cg<double>;

# print ginkgo library version
Ginkgo.get_version()

# if hidden
#     const auto executor_string = argc >= 2 ? argv[1] : "reference";
#     std::map<std::string, std::function<std::shared_ptr<gko::Executor>()>>
#         exec_map{
#             {"omp", [] { return gko::OmpExecutor::create(); }},
#             {"cuda",
#              [] {
#                  return gko::CudaExecutor::create(0,
#                                                   gko::OmpExecutor::create());
#              }},
#             {"hip",
#              [] {
#                  return gko::HipExecutor::create(0, gko::OmpExecutor::create());
#              }},
#             {"dpcpp",
#              [] {
#                  return gko::DpcppExecutor::create(0,
#                                                    gko::OmpExecutor::create());
#              }},
#             {"reference", [] { return gko::ReferenceExecutor::create(); }}};
    
#     const auto exec = exec_map.at(executor_string)();  // throws if not valid
# end

# exec = Ginkgo.create!(:reference)
exec = Ginkgo.create!(:hey)


# auto A = gko::share(gko::read<mtx>(std::ifstream("data/A.mtx"), exec));

# auto b = gko::read<vec>(std::ifstream("data/b.mtx"), exec);
# auto x = gko::read<vec>(std::ifstream("data/x0.mtx"), exec);

# gko::array<T> x(exec,2);
# auto A = gko::array<T>(exec,2);
A = Ginkgo.Array{Float64}(undef, exec, 2)

# B = Ginkgo.Array{Int64}(undef, exec, 2)

# C = Ginkgo.Array{String}(undef, exec, 2, 3)

# std::unique_ptr<gko::Dense<double>> b = gko::read<vec>(std::ifstream("data/b.mtx"), exec);
# std::unique_ptr<gko::Dense<double>> x = gko::read<vec>(std::ifstream("data/x0.mtx"), exec);

# b = Ginkgo.read!(, )


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

# std::cout << "Solution (x):\n";
println("Solution (x):")


# write(std::cout, x);

# auto one = gko::initialize<vec>({1.0}, exec);
# auto neg_one = gko::initialize<vec>({-1.0}, exec);
# auto res = gko::initialize<real_vec>({0.0}, exec);



# A->apply(one, x, neg_one, b);
# b->compute_norm2(res);

# std::cout << "Residual norm sqrt(r^T r):\n";
println("Residual norm sqrt(r^T r):")


# write(std::cout, res);

