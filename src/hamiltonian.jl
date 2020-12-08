# a term in the Hamiltonian
struct Term{T<:Real}
    # real numerical coefficient
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

# a Hamiltonian
mutable struct Hamiltonian
    nothing
end
