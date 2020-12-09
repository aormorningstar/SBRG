# a term in the Hamiltonian
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
abs(T::Term) = abs(T.h)

# a Hamiltonian
mutable struct Hamiltonian
    # terms
    T::Vector{Term}
end

# number of terms in the Hamiltonian
numterms(H::Hamiltonian) = length(H.T)

# index Hamiltonian to get term
getindex(H::Hamiltonian, i) = getindex(H.T, i)

# set term in the Hamiltonian
setindex!(H::Hamiltonian, T::Term, i) = setindex!(H.T, T, i)
