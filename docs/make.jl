using ImageNoise
using Documenter, DemoCards

templates, theme = cardtheme()
examples, postprocess_cb = makedemos("examples", templates)

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = [theme])

makedocs(modules  = [ImageNoise],
         format   = format,
         sitename = "ImageNoise",
         pages    = [
             "Home" => "index.md",
             "Examples" => examples,
             "References" => "reference.md"
        ])

postprocess_cb()

deploydocs(repo = "github.com/johnnychen94/ImageNoise.jl.git")
