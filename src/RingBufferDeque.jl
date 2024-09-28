module RingBufferDeque
export RBDeque

mutable struct RBDeque{T} <: AbstractVector{T}
    buf::Vector{T}
    offset::Int
    len::Int
    empty_value::T
end

RBDeque{T}(; empty_value=zero(T)) where T =
    RBDeque([empty_value], 0, 0, empty_value)

Base.propertynames(::RBDeque{T}, private::Bool=false) where T =
    private ? (:buf, :offset, :len, :empty_value, :cap, :len) : ()

function Base.getproperty(d::RBDeque{T}, s::Symbol) where T
    if s === :cap
        return length(getfield(d, :buf))
    else
        return getfield(d, s)
    end
end

Base.size(d::RBDeque{T}) where T = (d.len,)

function Base.push!(d::RBDeque{T}, value::T) where T
    if d.len == d.cap
        increase_capacity!(d)
    end

    idx = ((d.offset + d.len) & (d.cap - 1)) + 1
    d.buf[idx] = value
    d.len += 1

    return d
end

function Base.pop!(d::RBDeque{T})::T where T
    if d.len < 1
        throw(ArgumentError("deque must be non-empty"))
    end

    idx = (d.len + d.offset - 1) & (d.cap - 1) + 1
    d.len -= 1
    value = d.buf[idx]
    d.buf[idx] = d.empty_value
    return value
end

function Base.pushfirst!(d::RBDeque{T}, value::T) where T
    if d.len == d.cap
        increase_capacity!(d)
    end

    idx = (d.offset + d.cap - 1) & (d.cap - 1) + 1
    d.buf[idx] = value
    d.offset = idx - 1
    d.len += 1

    return d
end

function Base.popfirst!(d::RBDeque{T})::T where T
    if d.len < 1
        throw(ArgumentError("deque must be non-empty"))
    end

    idx = d.offset + 1
    value = d.buf[idx]
    d.buf[idx] = d.empty_value
    d.len -= 1
    d.offset = idx & (d.cap - 1)
    return value
end

function increase_capacity!(d::RBDeque{T}) where T
    old_cap = d.cap
    append!(d.buf, d.empty_value for i in 1 : old_cap)
    
    n_items_to_move = d.offset - old_cap + d.len
    v1 = @view d.buf[1 : n_items_to_move]
    v2 = @view d.buf[old_cap + 1 : old_cap + n_items_to_move]

    copy!(v2, v1)
    fill!(v1, d.empty_value)

    return nothing
end

function Base.getindex(d::RBDeque{T}, i::Int)::T where T
    idx = (i + d.offset - 1) & (d.cap - 1) + 1
    return d.buf[idx]
end

function Base.setindex!(d::RBDeque{T}, v::T, i::Int)::RBDeque{T} where T
    idx = (i + d.offset - 1) & (d.cap - 1) + 1
    d.buf[idx] = v
    return d
end

end # module
