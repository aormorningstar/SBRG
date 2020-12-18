# a Hamiltonian
struct RGHamiltonian
    # terms that anticommute with some other terms
    A::Vector{Term}
    # terms that commute with all other terms
    C::Vector{Term}
end

# constructor
RGHamiltonian(A::Vector{Term}) = RGHamiltonian(A, typeof(A)[])

# retrieve largest anticommuting term
function popH0!(H::RGHamiltonian)
    # init values to be overridden
    iH0 = -1
    h0 = 0.
    # run over all terms and compare
    for (i, T) in enumerate(H.A)
        h = norm(T)
        if h > h0
            # this term is the largest so far
            iH0 = i
            h0 = h
        end
    end
    # return H0 and remove it from H
    H0 = H.A[iH0]
    deleteat!(H.A, iH0)
    H0
end

# retrieve terms that anticommute with H0
function popS!(H::RGHamiltonian, H0::Term)
    # terms that anticommute with H0
    iS = Int[]
    for (i, T) in enumerate(H.A)
        if anticommute(T, H0)
            push!(iS, i)
        end
    end
    S = H.A[iS]
    deleteat!(H.A, iS)
    S
end

# compute the renormalized H0 ("on diagonal" Schrieffer-Wolff term)
function renormalizeH0(H0::Term, S::Vector{Term})
    # sum of h^2 over terms in S
    sumh2 = 0.
    for T in S
        sumh2 += T.h^2
    end
    # renormalized h0
    h0r = H0.h + sumh2 / (2 * H0.h)
    # renormalized H0
    h0r * H0.O
end

# compute the "off diagonal" Schrieffer-Wolff terms
function schriefferwolff(H0::Term, S::Vector{Term})
    # "off diagonal" terms in the SW correction
    SW = Term[]
    lS = length(S)
    for i in 1:lS
        for j in i+1:lS
            if commute(S[i], S[j])
                push!(SW, ((1 / H0.h) * H0.O) * S[i] * S[j])
            end
        end
    end
    # combine terms by adding them
    combine!(SW)
    # drop any zero terms
    dropzeros!(SW)
    SW
end

# perform an RG step
function step!(H::RGHamiltonian, maxrate::Int = 2)
    # retrieve the largest term
    H0 = popH0!(H)
    # retrieve anticommuting terms
    S = popS!(H, H0)
    # the renormalized H0 term
    rH0 = renormalizeH0(H0, S)
    # add the renormalized H0 to H
    push!(H.C, rH0)
    # the SW terms
    SW = schriefferwolff(H0, S)
    # truncate SW terms
    maxlen = maxrate * length(S)
    if maxlen < length(SW)
        sort!(SW, by=norm, rev=true)
        resize!(SW, maxlen)
    end
    # add SW terms to H
    append!(H.A, SW)
    # add terms together if possible and drop zeros
    combine!(H.A)
    dropzeros!(H.A)
    # return the G value of this step
    isempty(S) ? nothing : log(maximum(norm, S)) - log(norm(H0))
end
