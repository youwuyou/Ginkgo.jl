# logo
const logo = raw"""
                           __   __
                        __/  ⧹ /   ⧹
                      _/   ⧹    /   `_
                     /   ⧹  ⧹  /   /   ⧹
                   (      ⧹  `    /     )
                     ` `           `  `
                          ` ⧹  / `      
                             |
                             |
                             |

"""

function greet(; kwargs...)
    printstyled(logo; bold=true, color=:yellow, kwargs...)
    printstyled("Welcome to Ginkgo.jl. \n"; bold=true)
    printstyled("https://github.com/youwuyou/Ginkgo.jl")
end



# Documentation
function _doc_external(typename, linkname)
    """
    - `$typename` man page [Ginkgo](https://ginkgo-project.github.io/ginkgo-generated-documentation/doc/master/$linkname.html)
    """
end