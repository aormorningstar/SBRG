using Test

# the source code to be tested
include("../src/SBRG.jl")

@testset "is_sorted_unique" begin
    # set up test arguments and outputs
    v1 = [1, 2, 5, 7]
    v2 = [1, 2, 5, 5, 7]
    v3 = [1, 2, 5, 7, 7]
    v4 = [1, 1, 2, 5, 7]
    v5 = [2, 1 , 2, 5, 7]
    args = (v1, v2, v3, v4, v5)
    outs = (true, false, false, false, false)
    # check for correctness
    for (arg, out) in zip(args, outs)
        @test is_sorted_unique(arg) == out
    end
end

@testset "size_intersection_sorted_unique" begin
    # set up some test arguments and outputs
    v1 = [1, 2, 3, 4]
    v2 = [1, 2]
    v3 = [2, 4]
    v4 = Int[]
    args = ((v1, v2), (v2, v1), (v1, v3), (v3, v1), (v1, v4), (v4, v1), (v4, v4))
    outs = (2, 2, 2, 2, 0, 0, 0)
    # check for correctness
    for (arg, out) in zip(args, outs)
        @test size_intersection_sorted_unique(arg...) == out
    end
end

@testset "symdiff_sorted_unique" begin
    # set up test arguments and outputs
    v1 = [2, 5, 7, 8, 10, 12, 15]
    v2 = [5, 8, 11, 12]
    v3 = Int[]
    args = ((v1, v2), (v2, v3), (v3, v3))
    outs = (
        [2, 7, 10, 11, 15],
        v2,
        v3,
    )
    # check for correctness
    for (arg, out) in zip(args, outs)
        @test all(symdiff_sorted_unique(arg...) .== out)
    end
end

@testset "union_sorted_unique" begin
    # set up test arguments and outputs
    v1 = [1, 4, 6, 7]
    v2 = [2, 5, 6]
    v3 = [4, 7, 9]
    v4 = Int[]
    args = ((v1, v2), (v1, v3), (v1, v4))
    outs = (
        [1, 2, 4, 5, 6, 7],
        [1, 4, 6, 7, 9],
        v1,
    )
    # check for correctness
    for (arg, out) in zip(args, outs)
        @test all(union_sorted_unique(arg...) .== out)
    end
end

@testset "Pauli & Term" begin
    # set up test arguments and outputs
    X1Y2 = Pauli(1, [1, 2], [2])
    X2Y3 = Pauli(1, [2, 3], [3])
    X1X2 = Pauli(0, [1, 2], Int64[])
    Z1Z2 = Pauli(0, Int64[], [1, 2])
    Y1Y2 = Pauli(0, [1, 2], [1, 2])
    T1 = Term(2, X1Y2)
    T2 = Term(3, X2Y3)
    # set up outputs
    X1Y2X2Y3 = Pauli(0, [1, 3], [2, 3])
    X2Y3X1Y2 = Pauli(2, [1, 3], [2, 3])
    T1T2 = Term(6, X1Y2X2Y3)
    # check for correctness
    @test X1Y2 == X1Y2
    @test X1Y2 != X2Y3
    @test X1Y2 * X2Y3 == X1Y2X2Y3
    @test X2Y3 * X1Y2 == X2Y3X1Y2
    @test !commute(X1Y2, X2Y3)
    @test commute(X1X2, Z1Z2)
    @test commute(X1X2, Y1Y2)
    @test commute(Y1Y2, Z1Z2)
    @test_throws AssertionError Pauli(5, Int64[], Int64[])
    @test_throws AssertionError Pauli(2, [2, 1], [1])
    @test all(sites(X1Y2) .== [1, 2])
    @test center(X1Y2) == 1.5
    @test T1*T2 == T1T2
end

@testset "RGHamiltonian" begin
    # some pauli operators on three sites
    X1X2 = Pauli(0, [1,2], Int[]);
    X2X3 = Pauli(0, [2,3], Int[]);
    Z1 = Pauli(0, Int[], [1])
    Z2 = Pauli(0, Int[], [2])
    Z3 = Pauli(0, Int[], [3])
    Os = (X1X2, X2X3, Z1, Z2, Z3)
    # coefficients
    hs = rand(length(Os))
    # hamiltonian
    H = RGHamiltonian([Term(h, O) for (h, O) in zip(hs, Os)])
end
