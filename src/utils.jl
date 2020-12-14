# check if vector is sorted and elements are not repeated (unique)
function is_sorted_unique(v::AbstractVector)
    isu = true
    for i in 2:length(v)
        if v[i] <= v[i-1]
            isu = false
            break
        end
    end
    isu
end

# number of elements in intersection of two sorted unique vectors
function size_intersection_sorted_unique(v1::T, v2::T) where T<:AbstractVector
    s1 = length(v1)
    s2 = length(v2)
    # number of intersections
    n = 0
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
            n += 1
            i1 += 1
            i2 += 1
        end
    end
    n
end

# the symmetric difference of two sorted unique vectors
function symdiff_sorted_unique(v1::T, v2::T) where T<:AbstractVector
    s1 = length(v1)
    s2 = length(v2)
    # empty symmetric difference to be added to
    sdiff = T()
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
function union_sorted_unique(v1::T, v2::T) where T<:AbstractArray
    s1 = length(v1)
    s2 = length(v2)
    # empty union to be added to
    uni = T()
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
