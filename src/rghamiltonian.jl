# a Hamiltonian
mutable struct RGHamiltonian
    # terms that anticommute with some other terms
    A::Vector{Term}
    # terms that commute with all other terms
    C::Vector{Term}
end

# constructor
RGHamiltonian(A::Vector{Term}) = RGHamiltonian(A, typeof(A)[])

# find index of largest anticommuting term
function findH0(H::RGHamiltonian)
    # run over all terms and compare
    imax = 1
    hmax = norm(H.A[imax])
    for i in 2:length(H.A)
        hi = norm(H.A[i])
        if hi > hmax
            # this term is the largest so far
            imax = i
            hmax = hi
        end
    end
    imax
end

# get H0 and Sigma
# delete the Sigma terms from H
# move H0 term from H.A to H.C
function split!(H::RGHamiltonian)
    # the largest term that anticommutes with another term
    iH0 = findH0(H)
    H0 = H.A[iH0]
    # terms that anticommute with H0
    iSigma = Int[]
    for i in 1:length(H.A)
        if anticommute(H.A[i], H0)
            push!(iSigma, i)
        end
    end
    Sigma = H.A[iSigma]
    # remove Sigma terms from H and classify H0 as commuting now
    insert!(iSigma, searchsortedfirst(iSigma, iH0), iH0)
    deleteat!(H.A, iSigma)
    push!(H.C, H0)
    H0, Sigma
end

# compute the Schrieffer-Wolff corection to the Hamiltonian
function SchriefferWolff(H0::Term, Sigma::Vector{Term})
    # number of terms in Sigma
    lSigma = length(Sigma)
    # terms in the SW correction
    SW = Term[]
    # the second-order factor
    coef = 1 / (2 * H0.h^2)
    # the "diagonal" terms of Sigma^2
    sumh2 = 0.
    for i in 1:lSigma
        sumh2 += Sigma[i].h^2
    end
    push!(SW, (coef * sumh2) * H0)
    # the "off diagonal" terms of Sigma^2
    for i in 1:lSigma
        for j in i+1:lSigma
            if commute(Sigma[i], Sigma[j])
                push!(SW, (2 * coef) * H0 * Sigma[i] * Sigma[j])
            end
        end
    end
    # simplify by combining terms that can be added together
    add!(SW)
    SW
end

# perform an RG step
function step!(H::RGHamiltonian)
    # split the Hamiltonian
    H0, Sigma = split!(H)
    # compute the second-order SW terms
    SW = SchriefferWolff(H0, Sigma)
    # add SW terms to the Hamiltonian and simplify
    append!(H.A, SW)
    add!(H.A)
    #= TODO
    thoroughly simplify the Hamiltonian:
        - find terms that commute in H.A and move to H.C
        - remove zero terms
    =#
end
