# FIXME: before
# const auto executor_string = argc >= 2 ? argv[1] : "reference";
# std::map<std::string, std::function<std::shared_ptr<gko::Executor>()>>
#     exec_map{
#         {"omp", [] { return gko::OmpExecutor::create(); }},
#         {"reference", [] { return gko::ReferenceExecutor::create(); }}};

# const auto exec = exec_map.at(executor_string)();  // throws if not valid

# TODO: now
# exec = create!(:ref)
# exec = create!(:omp)



# OpenMP executor
# const std::shared_ptr<gko::OmpExecutor> exec = gko::OmpExecutor::create()


# Reference executor
# const auto exec = gko::ReferenceExecutor::create()