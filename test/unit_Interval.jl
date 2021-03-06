import IntervalArithmetic

for N in [Float64, Float32, Rational{Int}]
    # random interval
    rand(Interval)

    # constructor from IntervalArithmetic.Interval
    x = Interval(IntervalArithmetic.Interval(N(0), N(1)))

    # constructor from a vector
    x = Interval(N[0, 1])

    # type-less constructor
    x = Interval(N(0), N(1))

    @test dim(x) == 1
    @test center(x) == N[0.5]
    @test min(x) == N(0) && max(x) == N(1)
    v = vertices_list(x)
    @test N[0] in v && N[1] in v
    # test interface method an_element and membership
    @test an_element(x) ∈ x
    # test containment
    @test (x ⊆ x) && !(x ⊆ N(0.2) * x) && (x ⊆ N(2) * x)
    @test ⊆(x, Interval(N(0), N(2)))
    @test !⊆(x, Interval(N(-1), N(0.5)))

    # radius_hyperrectangle
    @test radius_hyperrectangle(x) == [N(0.5)]
    @test radius_hyperrectangle(x, 1) == N(0.5)

    # + operator (= concrete Minkowski sum of intervals)
    y = Interval(N(-2), N(0.5))
    m = x + y
    @test dim(m) == 1
    @test σ(N[1], m) == N[1.5]
    @test σ(N[-1], m) == N[-2]
    @test min(m) == N(-2) && max(m) == N(1.5)
    v = vertices_list(m)
    @test N[1.5] in v && N[-2] in v

    # difference
    d = x - y
    @test dim(d) == 1
    @test σ(N[1], d) == N[3]
    @test σ(N[-1], d) == N[-0.5]
    @test min(d) == N(-0.5) && max(d) == N(3)
    v = vertices_list(d)
    @test N[-0.5] in v && N[3] in v

    # product of intervals: use the * operator
    p = x * y
    @test dim(p) == 1
    @test σ(N[1], p) == N[0.5]
    @test σ(N[-1], p) == N[-2]
    v = vertices_list(p)
    @test N[0.5] in v && N[-2] in v

    # test different arithmetic operations
    r = (x + y) - (d + p)
    @test min(r) == N(-5.5) && max(r) == N(4)

    # isempty
    @test !isempty(x)

    # Minkowski sum (test that we get the same results as the concrete operation)
    m = x ⊕ y
    @test m isa MinkowskiSum
    @test dim(m) == 1
    @test σ(N[1], m) == N[1.5]
    @test σ(N[-1], m) == N[-2]

    # boundedness
    @test isbounded(x)

    # cartesian product
    cp = x × y
    @test cp isa CartesianProduct
    @test dim(cp) == 2

    # conversion to hyperrectangle
    h = convert(Hyperrectangle, x)
    @test h isa Hyperrectangle && center(h) == radius_hyperrectangle(h) == N[0.5]

    # concrete intersection
    A = Interval(N(5), N(7))
    B = Interval(N(3), N(6))
    C = intersection(A, B)
    @test C isa Interval
    @test min(C) == N(5) && max(C) == N(6)
    # check empty intersection
    E = intersection(A, Interval(N(0), N(1)))
    @test isempty(E)
end
