# Conversion between set representations

This section of the manual lists the conversion functions between set
representations.

```@contents
Pages = ["conversion.md"]
Depth = 3
```

```@meta
CurrentModule = LazySets
DocTestSetup = quote
    using LazySets
end
```

```@docs
convert(::Type{HPOLYGON1}, ::HPOLYGON2) where {HPOLYGON1<:AbstractHPolygon, HPOLYGON2<:AbstractHPolygon}
convert(::Type{HPOLYGON}, ::VPolygon) where {HPOLYGON<:AbstractHPolygon}
convert(::Type{Hyperrectangle}, ::Interval)
convert(::Type{HPOLYGON}, ::AbstractHyperrectangle) where {HPOLYGON<:AbstractHPolygon}
convert(::Type{HPOLYGON}, ::HPolytope{N}) where {N<:Real, HPOLYGON<:AbstractHPolygon}
convert(::Type{HPOLYGON}, ::AbstractSingleton{N}) where {N<:Real, HPOLYGON<:AbstractHPolygon}
convert(::Type{HPOLYGON}, ::LineSegment{N}) where {N<:Real, HPOLYGON<:AbstractHPolygon}
convert(::Type{HPolyhedron}, ::AbstractPolytope)
convert(::Type{HPolytope}, ::AbstractHPolygon)
convert(::Type{HPolytope}, ::AbstractHyperrectangle)
convert(::Type{HPolytope}, ::AbstractPolytope)
convert(::Type{HPolytope}, ::VPolytope)
convert(::Type{VPolygon}, ::AbstractHPolygon)
convert(::Type{VPolygon}, ::AbstractPolytope)
convert(::Type{VPolytope}, ::AbstractPolytope)
convert(::Type{VPolytope}, ::HPolytope)
convert(::Type{Zonotope}, ::AbstractHyperrectangle)
```
