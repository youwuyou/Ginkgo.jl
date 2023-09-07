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
        canonical="https://youwuyou.github.io/Ginkgo.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/youwuyou/Ginkgo.jl",
    devbranch="main",
)
