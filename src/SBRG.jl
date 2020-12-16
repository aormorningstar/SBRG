import Base: show, +, *, ==, size, getindex, setindex!, show, intersect, symdiff, union, push!, append!

# vectors with elements that are sorted and unique
include("suvector.jl")
# pauli group elements
include("pauli.jl")
# hamiltonian and rg
include("rghamiltonian.jl")
