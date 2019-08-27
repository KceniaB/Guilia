namedtuple(d::Dict{Symbol,T}) where {T} = NamedTuple{Tuple(keys(d))}(values(d))
