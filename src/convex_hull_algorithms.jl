"""
    convex_hull(points; [algorithm]::String="monotone_chain")

Compute the convex hull of points in the plane.

### Input

- `points`    -- list of 2D vectors
- `algorithm` -- (optional, default: `"monotone_chain"`) the convex hull
                 algorithm, valid options are:

    * `"monotone_chain"`

### Output

The convex hull as a list of 2D vectors with the coordinates of the points.

### Examples

Compute the convex hull of a random set of points:

```jldoctest ch_label
julia> points = [randn(2) for i in 1:30]; # 30 random points in 2D

julia> hull = convex_hull(points);

julia> typeof(hull)
Array{Array{Float64,1},1}
```

Plot both the random points and the computed convex hull polygon:

```jldoctest ch_label
julia> using Plots;

julia> plot([Tuple(pi) for pi in points], seriestype=:scatter);

julia> plot!(VPolygon(hull), alpha=0.2);
```
"""
function convex_hull(points; algorithm::String="monotone_chain")
    return convex_hull!(copy(points), algorithm=algorithm)
end

"""
    convex_hull!(points; algorithm::String="monotone_chain")

Compute the convex hull of points in the plane, in-place.

### Input

- `points`    -- list of 2D vectors (is modified)
- `algorithm` -- (optional, default: `"monotone_chain"`) the convex hull
                 algorithm, valid options are:

    * `"monotone_chain"`

### Notes

See the non-modifying version `convex_hull` for more details.
"""
function convex_hull!(points; algorithm::String="monotone_chain")
    length(points) == 1 || length(points) == 2 && return points

    if algorithm == "monotone_chain"
        return monotone_chain!(points)
    else
        error("the convex hull algorithm $algorithm is unknown")
    end
end

"""
    right_turn(O, A, B)

Determine if the acute angle defined by the three points `O`, `A`, `B` in the
plane is a right turn (counter-clockwise) with respect to the center `O`.

### Input

- `O` -- center point
- `A` -- one point
- `B` -- another point

### Algorithm

The [cross product](https://en.wikipedia.org/wiki/Cross_product) is used to
determine the sense of rotation. If the result is 0, the points are collinear;
if it is positive, the three points constitute a positive angle of rotation
around `O` from `A` to `B`; otherwise they constitute a negative angle.
"""
@inline right_turn(O, A, B) =
    (A[1] - O[1]) * (B[2] - O[2]) - (A[2] - O[2]) * (B[1] - O[1])

"""
    monotone_chain!(points::Vector{S}) where {S<:AbstractVector{N}} where {N<:Real}

Compute the convex hull of points in the plane using Andrew's monotone chain
method.

### Input

- `points` -- list of 2D vectors; is sorted in-place inside this function

### Output

List of vectors containing the 2D coordinates of the corner points of the
convex hull.

### Notes

For large sets of points, it is convenient to use static vectors to get
maximum performance. For information on how to convert usual vectors
into static vectors, see the type `SVector` provided by the
[StaticArrays](http://juliaarrays.github.io/StaticArrays.jl/stable/)
package.

### Algorithm

This function implements Andrew's monotone chain convex hull algorithm to
construct the convex hull of a set of ``n`` points in the plane in
``O(n \\log n)`` time.
For further details see
[Monotone chain](https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain)
"""
function monotone_chain!(points::Vector{S}) where {S<:AbstractVector{N}} where {N<:Real}

    @inline function build_hull!(semihull, iterator, points, zero_N)
        @inbounds for i in iterator
            while length(semihull) >= 2 &&
                    (right_turn(semihull[end-1], semihull[end], points[i])
                         <= zero_N)
                pop!(semihull)
            end
            push!(semihull, points[i])
        end
    end

    # sort the rows lexicographically (which requires a two-dimensional array)
    # points = sortrows(hcat(points...)', alg=QuickSort)  # out-of-place version
    sort!(points, by=x->(x[1], x[2]))                     # in-place version

    zero_N = zero(N)

    # build lower hull
    lower = Vector{S}()
    build_hull!(lower, indices(points)[1], points, zero_N)

    # build upper hull
    upper = Vector{S}()
    build_hull!(upper, reverse(indices(points)[1]), points, zero_N)

    # remove the last point of each segment because they are repeated
    copy!(points, @view(lower[1:end-1]))
    copy!(points, length(lower), @view(upper[1:end-1]))
    return resize!(points, length(lower) + length(upper) - 2)
end
