using Documenter, ImageNoise

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true")

makedocs(modules  = [ImageNoise],
         format   = format,
         sitename = "ImageNoise",
         pages    = [
             "Home" => "index.md",
             "References" => "reference.md"
        ])

deploydocs(repo = "github.com/johnnychen94/ImageNoise.jl.git")
