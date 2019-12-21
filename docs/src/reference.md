# [Package References](@id package_references)

```@contents
Pages = ["reference.md"]
Depth = 2
```

## ApplyNoise

`ApplyNoise` module provides several noise prototypes.

```@autodocs
Modules = [ImageNoise.ApplyNoise]
Order   = [:type, :function, :macro]
```

## ReduceNoise

`ReduceNoise` module provides several noise reduction algorithms.

```@autodocs
Modules = [ImageNoise.ReduceNoise]
Order   = [:type, :function, :macro]
```

## NoiseAPI

NoiseAPI is an _experimental_ module on unifying the API of different denoise algorithms.
This is used by algorithm develpers, users are not expected to use this module directly.

```@autodocs
Modules = [ImageNoise.NoiseAPI]
Order   = [:type, :function, :macro]
```