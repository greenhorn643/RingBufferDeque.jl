using RingBufferDeque
using Test

function lengthtest(n, m=1000)
    d = RBDeque{Int}()

    length_matches_expected = true

    for i in 1:n
        x = rand(-m:m)

        f_or_b = rand(1:2)

        if f_or_b == 1
            pushfirst!(d, x)
        else
            push!(d, x)
        end

        if length(d) != i
            length_matches_expected = false
            break
        end
    end

    @test length_matches_expected
end

function pushtest(n, m=1000)
    d = RBDeque{Int}()
    v = Vector{Int}()

    for _ in 1:n
        x = rand(-m:m)

        f_or_b = rand(1:2)

        if f_or_b == 1
            pushfirst!(d, x)
            pushfirst!(v, x)
        else
            push!(d, x)
            push!(v, x)
        end
    end

    @test collect(d) == v
end

function poptest(n, m=1000)
    v = [rand(-m:m) for _ in 1 : n]
    d = RBDeque{Int}()
    for x in v
        push!(d, x)
    end

    popped_v = zeros(Int, 0)
    popped_d = zeros(Int, 0)

    for _ in 1 : n
        f_or_b = rand(1:2)

        if f_or_b == 1
            push!(popped_v, popfirst!(v))
            push!(popped_d, popfirst!(d))
        else
            push!(popped_v, pop!(v))
            push!(popped_d, pop!(d))
        end
    end

    @test popped_v == popped_d && length(d) == 0
end

@testset "RingBufferDeque.jl" begin
    @test collect(RBDeque{Int}()) == []
    @test_throws ArgumentError pop!(RBDeque{Int}())
    @test_throws ArgumentError popfirst!(RBDeque{Int}())
    lengthtest(10000)
    pushtest(10)
    pushtest(100)
    pushtest(1000)
    pushtest(10000)
    poptest(10)
    poptest(100)
    poptest(1000)
    poptest(10000)
end