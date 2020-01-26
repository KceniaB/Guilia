namedtuple(d::Dict{Symbol,T}) where {T} = NamedTuple{Tuple(keys(d))}(values(d))
namedtuple(d::Dict{String,T}) where {T} = NamedTuple{Tuple(keys(d))}(values(d))

"""
´rescale´
rescale(t::IndexedTables.IndexedTable)

given a table of recombinase analysis result for photometry reshift the data to 0 on the center of the offset
"""
function rescale(t)
    @apply t :g flatten = true begin
        @transform {pos = :x == 0}
        @transform_vec {val = :y .- :y[:pos]}
    end
end
