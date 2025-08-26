using Ginkgo
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(Ginkgo, :DocTestSetup, :(using Ginkgo); recursive=true)

makedocs(
    sitename = "Ginkgo.jl",
    authors = "You Wu",
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/youwuyou/Ginkgo.jl",
        devbranch = "main",
        devurl = "dev",
        deploy_url = "https://ginkgo-for-julia.org/"
    ),
    modules = [Ginkgo],
    warnonly = [:missing_docs],
    pages = [
        "Home" => "index.md",
        "Concepts" => [
            "concepts/executor.md",
        ],
        "Programmer Guide" => [
            "programmer-guide/CONTRIBUTING.md",
            "programmer-guide/use-ginkgo-in-julia.md",
            "programmer-guide/ginkgo-c-library-api.md",
            "programmer-guide/debugging.md",
        ],
        "Reference" => [
            "reference/ginkgo-api.md",
            "reference/ginkgo-preferences.md",
            "reference/low-level-api.md",
        ],
        "Performance" => "performance.md",
    ]
)

deploydocs(
    repo = "github.com/youwuyou/Ginkgo.jl",
    devbranch = "main",
    push_preview = true
)