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

# do two paulis commute?
function commute(O1::Pauli, O2::Pauli)
    sb2a1 = size_intersection_sorted_unique(O2.b, O1.a)
    sb1a2 = size_intersection_sorted_unique(O1.b, O2.a)
    iseven(sb2a1 - sb1a2)
end

# sorted sites on which the pauli has non-identity action
sites(O::Pauli) = union_sorted_unique(O.a, O.b)

# center location of the pauli operator
function center(O::Pauli)
    la = length(O.a)
    lb = length(O.b)
    if la > 0 && lb > 0
        return (min(O.a[1], O.b[1]) + min(O.a[end], O.b[end])) / 2.
    elseif la == 0 && lb > 0
        return (O.b[1] + O.b[end]) / 2.
    elseif la > 0 && lb == 0
        return (O.a[1] + O.a[end]) / 2.
    else
        return 0.
    end
end

# a term in a Hamiltonian
struct Term{T<:Real}
    # energy coefficient
    h::T
    # pauli group element
    O::Pauli
end

# multiply two terms
function *(T1::Term, T2::Term)
    h = T1.h * T2.h
    O = T1.O * T2.O
    Term(h, O)
end

# are two terms proportional?
prop(T1::Term, T2::Term) = prop(T1.O, T2.O)

# are two terms equal?
(==)(T1::Term, T2::Term) = T1.h == T2.h && T1.O == T2.O

# norm is given by magnitude of coefficient
norm(T::Term) = abs(T.h)

# center location of the term
center(T::Term) = center(T.O)
