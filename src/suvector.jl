# check if vector is sorted and elements are unique
function _checksu(v::AbstractVector)
    isu = true
    for i in 2:length(v)
        if v[i] <= v[i-1]
            isu = false
            break
        end
    end
    isu
end

# a vector whose elements are sorted and unique
struct SUVector{T} <: AbstractVector{T}
    # elements are stored in a standard vector
    data::Vector{T}
    # constructor
    function SUVector(data::AbstractVector{T}) where T
        # check sorted and unique properties
        @assert _checksu(data)
        # NOTE: data is not copied
        new{T}(data)
    end
end

# empty constructor
SUVector{T}() where T = SUVector(T[])

# formatted printing
show(io::IO, v::SUVector) = show(io::IO, v.data)

# shape of the vector
size(v::SUVector) = size(v.data)

# indexed reading
getindex(v::SUVector, i::Int) = getindex(v.data, i)

# indexed writing
function setindex!(v::SUVector, vi, i::Int)
    # check to make sure order and uniqueness of elements is preserved
    l = length(v)
    if l > 1
        errmsg = "This doesn't preserve order or uniqueness of elements."
        if i == 1
            @assert vi < v[i+1] errmsg
        elseif i == l
            @assert v[i-1] < vi errmsg
        else
            @assert v[i-1] < vi < v[i+1] errmsg
        end
    end
    setindex!(v.data, vi, i)
end

# pushing an element onto the end of a sorted unique vector
function push!(v::SUVector{T}, el::T) where T
    if !isempty(v)
        @assert el > v[end] "Must be larger than current last element."
    end
    push!(v.data, el)
end

# appending elements onto the end of a sorted unique vector
function append!(v::SUVector{T}, els::AbstractVector{T}) where T
    if !isempty(v)
        errmsg = "Doesn't preserve order or uniqueness of elements."
        @assert _checksu(els) && els[1] > v[end] errmsg
    end
    append!(v.data, els)
end

# intersection of two sorted unique vectors
function intersect(v1::SUVector{T}, v2::SUVector{T}) where T
    s1 = length(v1)
    s2 = length(v2)
    # empty intersection to be added to
    int = SUVector{T}()
    # step through vectors simultaneously
    i1 = 1
    i2 = 1
    while i1 <= s1 && i2 <= s2
        if v1[i1] < v2[i2]
            # not an intersection, move towards one
            i1 += 1
        elseif v2[i2] < v1[i1]
            # not an intersection, move towards one
            i2 += 1
        else
            # an intersection
            push!(int, v1[i1])
            i1 += 1
            i2 += 1
        end
    end
    int
end

# symmetric difference of two sorted unique vectors
function symdiff(v1::SUVector{T}, v2::SUVector{T}) where T
    s1 = length(v1)
    s2 = length(v2)
    # empty symmetric difference to be added to
    sdiff = SUVector{T}()
    if s1 == 0
        # v1 is empty, so return all of v2
        append!(sdiff, v2)
    elseif s2 == 0
        # v2 is empty, so return all of v1
        append!(sdiff, v1)
    else
        # step through vectors simultaneously
        i1 = 1
        i2 = 1
        while i1 <= s1 && i2 <= s2
            if v1[i1] < v2[i2]
                # add to sdiff and move towards and intersection
                push!(sdiff, v1[i1])
                i1 += 1
            elseif v2[i2] < v1[i1]
                # add to sdiff and move towards and intersection
                push!(sdiff, v2[i2])
                i2 += 1
            else
                # intersection
                i1 += 1
                i2 += 1
            end
        end
        # once one vector is finished, add the rest of the other vector
        if i1 > s1 && i2 <= s2
            append!(sdiff, view(v2, i2:s2))
        elseif i2 > s2 && i1 <= s1
            append!(sdiff, view(v1, i1:s1))
        end
    end
    sdiff
end

# union of two sorted unique vectors
function union(v1::SUVector{T}, v2::SUVector{T}) where T
    s1 = length(v1)
    s2 = length(v2)
    # empty union to be added to
    uni = SUVector{T}()
    if s1 == 0
        # v1 is empty, return all of v2
        append!(uni, v2)
    elseif s2 == 0
        # v2 is empty, return all of v1
        append!(uni, v1)
    else
        # step through vectors simultaneously
        i1 = 1
        i2 = 1
        while i1 <= s1 && i2 <= s2
            if v1[i1] < v2[i2]
                # add to union and move towards an intersection
                push!(uni, v1[i1])
                i1 += 1
            elseif v2[i2] < v1[i1]
                # add to union and move towards and intersection
                push!(uni, v2[i2])
                i2 += 1
            else
                # intersection, only add one but increment both
                push!(uni, v1[i1])
                i1 += 1
                i2 += 1
            end
        end
        # when finished one of the vectors, add the rest of the other
        if i1 > s1 && i2 <= s2
            append!(uni, view(v2, i2:s2))
        elseif i2 > s2 && i1 <= s1
            append!(uni, view(v1, i1:s1))
        end
    end
    uni
end
