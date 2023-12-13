using Ginkgo
using Documenter

DocMeta.setdocmeta!(Ginkgo, :DocTestSetup, :(using Ginkgo); recursive=true)

makedocs(;
    modules=[Ginkgo],
    authors="You Wu",
    repo="https://github.com/youwuyou/Ginkgo.jl/blob/{commit}{path}#{line}",
    sitename="Ginkgo.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
	repolink="https://github.com/youwuyou/Ginkgo.jl",
        canonical="https://youwuyou.github.io/Ginkgo.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Concepts" =>
        [
            "concepts/executor.md",
        ],
        "Programmer Guide" =>
        [   
            "programmer-guide/CONTRIBUTING.md",
            "programmer-guide/use-ginkgo-in-julia.md",
            "programmer-guide/ginkgo-c-library-api.md",
            "programmer-guide/debugging.md",
        ],
        "Reference" => 
        [   
            "reference/ginkgo-api.md",
            "reference/low-level-api.md",
        ],
        "Performance" => "performance.md",
        "Index" => "reindex.md",
    ],
)

deploydocs(;
    repo="github.com/youwuyou/Ginkgo.jl",
    devbranch="main",
)
