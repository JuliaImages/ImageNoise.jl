using Documenter, ImageNoise

makedocs(modules  = [ImageNoise],
    sitename = "ImageNoise",
    pages    = ["index.md"])

deploydocs(repo = "github.com/johnnychen94/ImageNoise.jl.git")
