# element of the Pauli group
struct Pauli
    # exponent of i in [0, 3]
    p::Int
    # nonrepeating sorted sites at which there's a X operator
    a::SUVector{Int}
    # nonrepeating sorted sites at which there's a Z operator
    b::SUVector{Int}
    # constructor
    function Pauli(p::Int, a::SUVector{Int}, b::SUVector{Int})
        @assert 0 <= p <= 3 "p must be in [0, 3]."
        new(p, a, b)
    end
end

# constructor
function Pauli(p::Int, a::Vector{Int}, b::Vector{Int})
    Pauli(p, SUVector(a), SUVector(b))
end

# multiply paulis
function *(O1::Pauli, O2::Pauli)
    # the exponent of i
    p = mod(O1.p + O2.p + 2*length(intersect(O1.b, O2.a)), 4)
    # X sites
    a = symdiff(O1.a, O2.a)
    # Z sites
    b = symdiff(O1.b, O2.b)
    Pauli(p, a, b)
end

# are two paulis proportional?
function prop(O1::Pauli, O2::Pauli)
    # check if pauli data matches
    size_check = size(O1.a) == size(O2.a) && size(O1.b) == size(O2.b)
    size_check ? all(O1.a .== O2.a) && all(O1.b .== O2.b) : false
end

# are two paulis equal?
(==)(O1::Pauli, O2::Pauli) = O1.p == O2.p && prop(O1, O2)

# do two paulis commute?
function commute(O1::Pauli, O2::Pauli)
    # number of sites with X in O1 or O2 and Z in the other
    iseven(
        length(intersect(O2.b, O1.a))
        - length(intersect(O1.b, O2.a))
    )
end

# do two paulis anticommute?
anticommute(O1::Pauli, O2::Pauli) = !commute(O1, O2)

# sorted sites on which the pauli has non-identity action
sites(O::Pauli) = union(O.a, O.b)

# center location of the pauli operator
function center(O::Pauli)
    la = length(O.a)
    lb = length(O.b)
    if la > 0 && lb > 0
        # some Xs and some Zs
        return (min(O.a[1], O.b[1]) + min(O.a[end], O.b[end])) / 2.
    elseif la == 0 && lb > 0
        # only Zs
        return (O.b[1] + O.b[end]) / 2.
    elseif la > 0 && lb == 0
        # only Xs
        return (O.a[1] + O.a[end]) / 2.
    else
        # no Xs or Zs (proportional to the identity)
        return 0.
    end
end

# a term in a Hamiltonian
struct Term
    # energy coefficient
    h::Float64
    # pauli group element
    O::Pauli
end

# multiply two terms
function *(T1::Term, T2::Term)
    # coefficient
    h = T1.h * T2.h
    # pauli
    O = T1.O * T2.O
    Term(h, O)
end

# multiply a real number and a pauli to get a term
*(h::Real, O::Pauli) = Term(h, O)

# multiply a term by a number
*(n::Real, T::Term) = Term(n * T.h, T.O)

# are two terms proportional?
prop(T1::Term, T2::Term) = prop(T1.O, T2.O)

# add two terms that are proportional
function +(T1::Term, T2::Term)
    @assert prop(T1, T2) "Terms must be proportional to add them."
    # account for possible relative sign between paulis
    dp = T2.O.p - T1.O.p
    @assert iseven(dp) "One of these terms is nonhermitian."
    h = T1.h + T2.h * (-1)^div(dp, 2)
    Term(h, T1.O)
end

# are two terms equal?
(==)(T1::Term, T2::Term) = T1.h == T2.h && T1.O == T2.O

# do two terms commute?
commute(T1::Term, T2::Term) = commute(T1.O, T2.O)

# do two terms anticommute?
anticommute(T1::Term, T2::Term) = anticommute(T1.O, T2.O)

# norm is given by magnitude of coefficient
norm(T::Term) = abs(T.h)

# center location of the term
center(T::Term) = center(T.O)

# combine terms when possible by adding them
function combine!(terms::Vector{Term})
    # elements to be deleted
    del = Int[]
    # loop over terms and try to add them together
    for i in 1:length(terms)
        # find first previous proportional term and add to it
        for j in 1:i-1
            if prop(terms[i], terms[j])
                push!(del, i)
                terms[j] += terms[i]
                break
            end
        end
    end
    # delete terms that we added to others
    deleteat!(terms, del)
    terms
end

# drop zero terms
function dropzeros!(terms::Vector{Term})
    # elements to be deleted
    del = Int[]
    # find zero terms
    for i in 1:length(terms)
        if terms[i].h == 0.
            push!(del, i)
        end
    end
    # delete the zeros
    deleteat!(terms, del)
    terms
end
