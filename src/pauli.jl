# element of the Pauli group
struct Pauli{T<:Integer}
    # exponent of i in [0, 3]
    p::Int64
    # nonrepeating sorted sites at which there's a X operator
    a::Vector{T}
    # nonrepeating sorted sites at which there's a Z operator
    b::Vector{T}
    # constructor
    function Pauli(p::Integer, a::Vector{T}, b::Vector{T}) where T<:Integer
        @assert 0 <= p <= 3 "p must be in [0, 3]."
        @assert is_sorted_unique(a) && is_sorted_unique(b) "a and b must be unique and sorted."
        new{T}(p, a, b)
    end
end

# multiply paulis
function *(O1::Pauli, O2::Pauli)
    p = mod(O1.p + O2.p + 2*size_intersection_sorted_unique(O1.b, O2.a), 4)
    a = symdiff_sorted_unique(O1.a, O2.a)
    b = symdiff_sorted_unique(O1.b, O2.b)
    Pauli(p, a, b)
end

# are two paulis proportional?
function prop(O1::Pauli, O2::Pauli)
    pr = false
    if size(O1.a) == size(O2.a) && size(O1.b) == size(O2.b)
        pr = all(O1.a .== O2.a) && all(O1.b .== O2.b)
    end
    pr
end

# are two paulis equal?
(==)(O1::Pauli, O2::Pauli) = O1.p == O2.p && prop(O1, O2)
