# a Hamiltonian
struct RGHamiltonian
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

# apply the Schrieffer-Wolff transformation to the Hamiltonian
function SchriefferWolff!(H::RGHamiltonian, iH0::Int)
    # the largest term that anticommutes with another term
    H0 = H.A[iH0]
    # terms that anticommute with H0
    iSigma = Int[]
    # sum of h^2 over terms in Sigma
    sumh2 = 0.
    # # log ratio of matrix element to level spacing
    # G = Float64[]
    for i in 1:length(H.A)
        if anticommute(H.A[i], H0)
            # this term is to be eliminated perturbatively
            push!(iSigma, i)
            # "diagonal" term contributes to renormalizing H0
            sumh2 += H.A[i].h^2
            # # parameter to justify perturbative treatment
            # push!(G, log(H.A[i].h) - log(H0.h))
        end
    end
    # renormalized h0
    h0r = H0.h + sumh2 / (2 * H0.h)
    # put the renormalized H0 into the commuting terms
    push!(H.C, h0r * H0.O)
    # "off diagonal" terms in the SW correction
    for i in iSigma
        for j in iSigma[iSigma .> i]
            if commute(H.A[i], H.A[j])
                push!(H.A, ((1 / H0.h) * H0.O) * H.A[i] * H.A[j])
            end
        end
    end
    # remove Sigma and H0 from anticommuting terms
    insert!(iSigma, searchsortedfirst(iSigma, iH0), iH0)
    deleteat!(H.A, iSigma)
    # simplify by combining terms that can be added together
    combine!(H.A)
    # drop any zero terms
    dropzeros!(H.A)
    # G
end

# perform an RG step
function step!(H::RGHamiltonian)
    # find the largest term
    iH0 = findH0(H)
    # apply the SW transformation
    SchriefferWolff!(H, iH0)
end
