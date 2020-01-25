mean_normalization(x) = x./mean(x)


function _normalized_density(x; npoints = 100, rescale, axis, kwargs...)
    nx = rescale(x)
    d = InterpKDE(kde(nx; kwargs...))
    return ((val, pdf(d, val)) for val in axis)
end

# function _normalized_frequency(x; rescale, axis, npoints = 100)
#     nx = rescale(x)
#     c = countmap(nx)
#     s = sum(values(c))
#     return ((val, get(c, val, 0)/s) for val in axis)
# end

funcs = (continuous = _normalized_density,)

NormalizedDensity = Recombinase.Analysis(
    funcs;
    rescale = x -> x ./ mean(x)
    ) |> Recombinase.continuous
#
# function Recombinase.compute_summary(f::Recombinase.Analysis{<:Any, typeof(funcs)},
#     keys::AbstractVector, cols::Tup; kwargs...)
#
#     an_kwargs = Dict(pairs(f.kwargs))
#     rescale = pop!(an_kwargs, :rescale)
#     an = Recombinase.continuous(Recombinase.density(; an_kwargs...))
#     Recombinase.compute_summary(an, keys, map(rescale, cols))
# end
