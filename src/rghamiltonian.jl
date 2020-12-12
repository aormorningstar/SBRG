# a Hamiltonian
mutable struct RGHamiltonian
    # terms reverse sorted by their norm
    T::Vector{Term}
    # cutoff index (first term that isn't an integral of motion)
    cut::Int
end

# number of terms in the Hamiltonian
numterms(H::RGHamiltonian) = length(H.T)

# index Hamiltonian to get term
getindex(H::RGHamiltonian, i) = getindex(H.T, i)

# set term in the Hamiltonian
setindex!(H::RGHamiltonian, T::Term, i) = setindex!(H.T, T, i)

# find maximum term
function findmax(H::RGHamiltonian)
    nothing
end

# split Hamiltonian into H0, Delta, Sigma
function split(H::RGHamiltonian)
    nothing
end

# perform an RG step
function step(H::RGHamiltonian)
    nothing
end
