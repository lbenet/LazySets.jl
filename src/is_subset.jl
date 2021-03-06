import Base.issubset


# --- AbstractHyperrectangle ---


"""
    ⊆(S::LazySet{N}, H::AbstractHyperrectangle{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a convex set is contained in a hyperrectangular set, and if not,
optionally compute a witness.

### Input

- `S` -- inner convex set
- `H` -- outer hyperrectangular set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``S ⊆ H``
* If `witness` option is activated:
  * `(true, [])` iff ``S ⊆ H``
  * `(false, v)` iff ``S ⊈ H`` and ``v ∈ S \\setminus H``

### Algorithm

``S ⊆ H`` iff ``\\operatorname{ihull}(S) ⊆ H``, where  ``\\operatorname{ihull}``
is the interval hull operator.
"""
function ⊆(S::LazySet{N}, H::AbstractHyperrectangle{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return ⊆(Approximations.interval_hull(S), H, witness)
end


"""
    ⊆(P::AbstractPolytope{N}, H::AbstractHyperrectangle, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a polytope is contained in a hyperrectangular set, and if not,
optionally compute a witness.

### Input

- `P` -- inner polytope
- `H` -- outer hyperrectangular set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``P ⊆ H``
* If `witness` option is activated:
  * `(true, [])` iff ``P ⊆ H``
  * `(false, v)` iff ``P ⊈ H`` and ``v ∈ P \\setminus H``

### Notes

This copy-pasted method just exists to avoid method ambiguities.

### Algorithm

Since ``H`` is convex, ``P ⊆ H`` iff ``v_i ∈ H`` for all vertices ``v_i`` of
``P``.
"""
function ⊆(P::AbstractPolytope{N},
           H::AbstractHyperrectangle,
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    @assert dim(P) == dim(H)

    for v in vertices_list(P)
        if !∈(v, H)
            if witness
                return (false, v)
            else
                return false
            end
        end
    end
    if witness
        return (true, N[])
    else
        return true
    end
end


"""
    ⊆(H1::AbstractHyperrectangle{N},
      H2::AbstractHyperrectangle{N},
      [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a given hyperrectangular set is contained in another
hyperrectangular set, and if not, optionally compute a witness.

### Input

- `H1` -- inner hyperrectangular set
- `H2` -- outer hyperrectangular set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``H1 ⊆ H2``
* If `witness` option is activated:
  * `(true, [])` iff ``H1 ⊆ H2``
  * `(false, v)` iff ``H1 ⊈ H2`` and ``v ∈ H1 \\setminus H2``

### Algorithm

``H1 ⊆ H2`` iff ``c_1 + r_1 ≤ c_2 + r_2 ∧ c_1 - r_1 ≥ c_2 - r_2`` iff
``r_1 - r_2 ≤ c_1 - c_2 ≤ -(r_1 - r_2)``, where ``≤`` is taken component-wise.
"""
function ⊆(H1::AbstractHyperrectangle{N},
           H2::AbstractHyperrectangle{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    @assert dim(H1) == dim(H2)

    for i in 1:dim(H1)
        c_dist = center(H1)[i] - center(H2)[i]
        r_dist = radius_hyperrectangle(H1, i) - radius_hyperrectangle(H2, i)
        if -r_dist < c_dist || c_dist < r_dist
            if witness
                # compute a witness 'p' in the difference
                p = copy(center(H1))
                if c_dist >= 0
                    p[i] += radius_hyperrectangle(H1, i)
                else
                    p[i] -= radius_hyperrectangle(H1, i)
                end
                return (false, p)
            else
                return false
            end
        end
    end

    if witness
        return (true, N[])
    else
        return true
    end
end


# --- AbstractPolytope ---


"""
    ⊆(P::AbstractPolytope{N}, S::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a polytope is contained in a convex set, and if not, optionally
compute a witness.

### Input

- `P` -- inner polytope
- `S` -- outer convex set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``P ⊆ S``
* If `witness` option is activated:
  * `(true, [])` iff ``P ⊆ S``
  * `(false, v)` iff ``P ⊈ S`` and ``v ∈ P \\setminus S``

### Algorithm

Since ``S`` is convex, ``P ⊆ S`` iff ``v_i ∈ S`` for all vertices ``v_i`` of
``P``.
"""
function ⊆(P::AbstractPolytope{N}, S::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    @assert dim(P) == dim(S)

    for v in vertices_list(P)
        if !∈(v, S)
            if witness
                return (false, v)
            else
                return false
            end
        end
    end
    if witness
        return (true, N[])
    else
        return true
    end
end

"""
    ⊆(S::LazySet{N},
      P::Union{AbstractPolytope{N}, HPolyhedron{N}, HalfSpace{N}},
      witness::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a convex set is contained in a polyhedron, and if not, optionally
compute a witness.

### Input

- `S` -- inner convex set
- `P` -- outer polyhedron (including a half-space)
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``S ⊆ P``
* If `witness` option is activated:
  * `(true, [])` iff ``S ⊆ P``
  * `(false, v)` iff ``S ⊈ P`` and ``v ∈ P \\setminus S``

### Algorithm

Since ``S`` is convex, we can compare the support function of ``S`` and ``P`` in
each direction of the constraints of ``P``.

For witness generation, we use the support vector in the first direction where
the above check fails.
"""
function ⊆(S::LazySet{N},
           P::Union{AbstractPolytope{N}, HPolyhedron{N}, HalfSpace{N}},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    @inbounds for H in constraints_list(P)
        if ρ(H.a, S) > H.b
            if witness
                return (false, σ(H.a, S))
            else
                return false
            end
        end
    end
    return witness ? (true, N[]) : true
end

# disambiguation
function ⊆(S::Union{AbstractPolytope{N}, AbstractHyperrectangle{N},
                    AbstractSingleton{N}, LineSegment{N}},
           P::Union{AbstractPolytope{N}, HPolyhedron{N}, HalfSpace{N}},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return invoke(⊆, Tuple{LazySet{N}, typeof(P), Bool}, S, P, witness)
end
function ⊆(P::AbstractPolytope{N},
           H::AbstractHyperrectangle{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return invoke(⊆,
                  Tuple{LazySet{N}, AbstractHyperrectangle{N}, Bool},
                  P, H, witness)
end


# --- AbstractSingleton ---


"""
    ⊆(S::AbstractSingleton{N}, set::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a given set with a single value is contained in a convex set, and
if not, optionally compute a witness.

### Input

- `S`   -- inner set with a single value
- `set` -- outer convex set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``S ⊆ \\text{set}``
* If `witness` option is activated:
  * `(true, [])` iff ``S ⊆ \\text{set}``
  * `(false, v)` iff ``S ⊈ \\text{set}`` and
    ``v ∈ S \\setminus \\text{set}``
"""
function ⊆(S::AbstractSingleton{N}, set::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    result = ∈(element(S), set)
    if witness
        return (result, result ? N[] : element(S))
    else
        return result
    end
end


"""
    ⊆(S::AbstractSingleton{N},
      H::AbstractHyperrectangle{N},
      [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a given set with a single value is contained in a hyperrectangular
set, and if not, optionally compute a witness.

### Input

- `S` -- inner set with a single value
- `H` -- outer hyperrectangular set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``S ⊆ H``
* If `witness` option is activated:
  * `(true, [])` iff ``S ⊆ H``
  * `(false, v)` iff ``S ⊈ H`` and ``v ∈ S \\setminus H``

### Notes

This copy-pasted method just exists to avoid method ambiguities.
"""
function ⊆(S::AbstractSingleton{N},
           H::AbstractHyperrectangle{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    result = ∈(element(S), H)
    if witness
        return (result, result ? N[] : element(S))
    else
        return result
    end
end


"""
    ⊆(S1::AbstractSingleton{N},
      S2::AbstractSingleton{N},
      [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a given set with a single value is contained in another set with a
single value, and if not, optionally compute a witness.

### Input

- `S1` -- inner set with a single value
- `S2` -- outer set with a single value
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``S1 ⊆ S2`` iff ``S1 == S2``
* If `witness` option is activated:
  * `(true, [])` iff ``S1 ⊆ S2``
  * `(false, v)` iff ``S1 ⊈ S2`` and ``v ∈ S1 \\setminus S2``
"""
function ⊆(S1::AbstractSingleton{N},
           S2::AbstractSingleton{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    result = element(S1) == element(S2)
    if witness
        return (result, result ? N[] : element(S1))
    else
        return result
    end
end


# --- Ball2 ---


"""
    ⊆(B1::Ball2{N}, B2::Ball2{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:AbstractFloat}

Check whether a ball in the 2-norm is contained in another ball in the 2-norm,
and if not, optionally compute a witness.

### Input

- `B1` -- inner ball in the 2-norm
- `B2` -- outer ball in the 2-norm
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``B1 ⊆ B2``
* If `witness` option is activated:
  * `(true, [])` iff ``B1 ⊆ B2``
  * `(false, v)` iff ``B1 ⊈ B2`` and ``v ∈ B1 \\setminus B2``

### Algorithm

``B1 ⊆ B2`` iff ``‖ c_1 - c_2 ‖_2 + r_1 ≤ r_2``
"""
function ⊆(B1::Ball2{N}, B2::Ball2{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:AbstractFloat}
    result = norm(B1.center - B2.center, 2) + B1.radius <= B2.radius
    if witness
        if result
            return (result, N[])
        end
    else
        return result
    end

    # compute a witness 'v'
    v = B1.center .+ B1.radius * (B1.center .- B2.center)
    return (false, v)
end


# --- Ball2/Ballp ---


"""
    ⊆(B::Union{Ball2{N}, Ballp{N}},
      S::AbstractSingleton{N},
      [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:AbstractFloat}

Check whether a ball in the 2-norm or p-norm is contained in a set with a single
value, and if not, optionally compute a witness.

### Input

- `B` -- inner ball in the 2-norm or p-norm
- `S` -- outer set with a single value
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``B ⊆ S``
* If `witness` option is activated:
  * `(true, [])` iff ``B ⊆ S``
  * `(false, v)` iff ``B ⊈ S`` and ``v ∈ B \\setminus S``
"""
function ⊆(B::Union{Ball2{N}, Ballp{N}},
           S::AbstractSingleton{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:AbstractFloat}
    result = B.center == element(S) && B.radius == 0
    if witness
        if result
            return (result, N[])
        end
    else
        return result
    end

    # compute a witness 'p' in the difference
    if B.center != element(S)
        p = B.center
    else
        p = copy(B.center)
        p[1] += B.radius
    end
    return (false, p)
end


# --- LineSegment ---


"""
    ⊆(L::LineSegment{N}, S::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a line segment is contained in a convex set, and if not,
optionally compute a witness.

### Input

- `L` -- inner line segment
- `S` -- outer convex set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``L ⊆ S``
* If `witness` option is activated:
  * `(true, [])` iff ``L ⊆ S``
  * `(false, v)` iff ``L ⊈ S`` and ``v ∈ L \\setminus S``

### Algorithm

Since ``S`` is convex, ``L ⊆ S`` iff ``p ∈ S`` and ``q ∈ S``, where ``p, q`` are
the end points of ``L``.
"""
function ⊆(L::LineSegment{N}, S::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    p_in_S = ∈(L.p, S)
    result = p_in_S && ∈(L.q, S)
    if !witness
        return result
    elseif result
        return (result, N[])
    else
        return (result, p_in_S ? L.q : L.p)
    end
end


"""
    ⊆(L::LineSegment{N}, H::AbstractHyperrectangle{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a line segment is contained in a hyperrectangular set, and if not,
optionally compute a witness.

### Input

- `L` -- inner line segment
- `H` -- outer hyperrectangular set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``L ⊆ H``
* If `witness` option is activated:
  * `(true, [])` iff ``L ⊆ H``
  * `(false, v)` iff ``L ⊈ H`` and ``v ∈ L \\setminus H``

### Notes

This copy-pasted method just exists to avoid method ambiguities.

### Algorithm

Since ``H`` is convex, ``L ⊆ H`` iff ``p ∈ H`` and ``q ∈ H``, where ``p, q`` are
the end points of ``L``.
"""
function ⊆(L::LineSegment{N}, H::AbstractHyperrectangle{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    p_in_H = ∈(L.p, H)
    result = p_in_H && ∈(L.q, H)
    if !witness
        return result
    elseif result
        return (result, N[])
    else
        return (result, p_in_H ? L.q : L.p)
    end
end


# --- Interval ---


"""
    ⊆(x::Interval, y::Interval)

Check whether an interval is contained in another interval.

### Input

- `x` -- interval
- `y` -- interval

### Output

`true` iff ``x ⊆ y``.
"""
function ⊆(x::Interval, y::Interval)
    return x.dat ⊆ y.dat
end


# --- EmptySet ---


"""
    ⊆(∅::EmptySet{N}, X::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether an empty set is contained in another set.

### Input

- `∅`       -- empty set
- `X`       -- another set
- `witness` -- (optional, default: `false`) compute a witness if activated
               (ignored, just kept for interface reasons)

### Output

`true`.
"""
function ⊆(∅::EmptySet{N}, X::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (true, N[]) : true
end

# disambiguation
function ⊆(∅::EmptySet{N},
           S::Union{AbstractPolytope{N}, HPolyhedron{N}, HalfSpace{N}},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (true, N[]) : true
end
function ⊆(∅::EmptySet{N},
           H::AbstractHyperrectangle{N},
           witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (true, N[]) : true
end

"""
    ⊆(X::LazySet{N}, ∅::EmptySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a set is contained in an empty set.

### Input

- `X`       -- another set
- `∅`       -- empty set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

`true` iff `X` is empty.

### Algorithm

We rely on `isempty(X)` for the emptiness check and on `an_element(X)` for
witness production.
"""
function ⊆(X::LazySet{N}, ∅::EmptySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    if isempty(X)
        return witness ? (true, N[]) : true
    else
        return witness ? (false, an_element(X)) : false
    end
end

# disambiguation
function ⊆(X::AbstractPolytope{N}, ∅::EmptySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    if isempty(X)
        return witness ? (true, N[]) : true
    else
        return witness ? (false, an_element(X)) : false
    end
end
function ⊆(X::AbstractSingleton{N}, ∅::EmptySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (false, an_element(X)) : false
end
function ⊆(X::LineSegment{N}, ∅::EmptySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (false, an_element(X)) : false
end
function ⊆(X::EmptySet{N}, ∅::EmptySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return witness ? (true, N[]) : true
end


# --- UnionSet ---


"""
    ⊆(cup::UnionSet{N}, X::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a union of two convex sets is contained in another set.

### Input

- `cup`     -- union of two convex sets
- `X`       -- another set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``\\text{cup} ⊆ X``
* If `witness` option is activated:
  * `(true, [])` iff ``\\text{cup} ⊆ X``
  * `(false, v)` iff ``\\text{cup} \\not\\subseteq X`` and
    ``v ∈ \\text{cup} \\setminus X``
"""
function ⊆(cup::UnionSet{N}, X::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    return ⊆(UnionSetArray([cup.X, cup.Y]), X, witness)
end

"""
    ⊆(cup::UnionSetArray{N}, X::LazySet{N}, [witness]::Bool=false
     )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}

Check whether a union of a finite number of convex sets is contained in another
set.

### Input

- `cup`     -- union of a finite number of convex sets
- `X`       -- another set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `true` iff ``\\text{cup} ⊆ X``
* If `witness` option is activated:
  * `(true, [])` iff ``\\text{cup} ⊆ X``
  * `(false, v)` iff ``\\text{cup} \\not\\subseteq X`` and
    ``v ∈ \\text{cup} \\setminus X``
"""
function ⊆(cup::UnionSetArray{N}, X::LazySet{N}, witness::Bool=false
          )::Union{Bool, Tuple{Bool, Vector{N}}} where {N<:Real}
    result = true
    w = N[]
    for Y in array(cup)
        if witness
            result, w = ⊆(Y, X, witness)
        else
            result = ⊆(Y, X, witness)
        end
        if !result
            break
        end
    end
    return witness ? (result, w) : result
end
