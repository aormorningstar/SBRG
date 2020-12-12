# check if vector is sorted and elements are unique
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

# the number of elements in the intersection of two sorted vectors of unique elements
function size_intersection_sorted_unique(v1::AbstractVector, v2::AbstractVector)
    s1 = length(v1)
    s2 = length(v2)
    n = 0
    i1 = 1
    i2 = 1
    while i1 <= s1 && i2 <= s2
        if v1[i1] < v2[i2]
            i1 += 1
        elseif v2[i2] < v1[i1]
            i2 += 1
        else
            n += 1
            i1 += 1
            i2 += 1
        end
    end
    n
end

# the symmetric difference of two sorted vectors of unique elements
function symdiff_sorted_unique(v1::T, v2::T) where T<:AbstractArray
    s1 = length(v1)
    s2 = length(v2)
    sdiff = T()
    if s1 == 0
        append!(sdiff, v2)
    elseif s2 == 0
        append!(sdiff, v1)
    else
        i1 = 1
        i2 = 1
        while i1 <= s1 && i2 <= s2
            if v1[i1] < v2[i2]
                push!(sdiff, v1[i1])
                i1 += 1
            elseif v2[i2] < v1[i1]
                push!(sdiff, v2[i2])
                i2 += 1
            else
                i1 += 1
                i2 += 1
            end
        end
        if i1 > s1 && i2 <= s2
            append!(sdiff, view(v2, i2:s2))
        elseif i2 > s2 && i1 <= s1
            append!(sdiff, view(v1, i1:s1))
        end
    end
    sdiff
end

# union of two sorted vectors of unique elements
function union_sorted_unique(v1::T, v2::T) where T<:AbstractArray
    s1 = length(v1)
    s2 = length(v2)
    uni = T()
    if s1 == 0
        append!(uni, v2)
    elseif s2 == 0
        append!(uni, v1)
    else
        i1 = 1
        i2 = 1
        while i1 <= s1 && i2 <= s2
            if v1[i1] < v2[i2]
                push!(uni, v1[i1])
                i1 += 1
            elseif v2[i2] < v1[i1]
                push!(uni, v2[i2])
                i2 += 1
            else
                push!(uni, v1[i1])
                i1 += 1
                i2 += 1
            end
        end
        if i1 > s1 && i2 <= s2
            append!(uni, view(v2, i2:s2))
        elseif i2 > s2 && i1 <= s1
            append!(uni, view(v1, i1:s1))
        end
    end
    uni
end
