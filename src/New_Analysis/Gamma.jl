function discrete_Gamma(v;axis = Recombinase.discrete_axis(v), kwargs...)
    if minimum(v) <= 0
        shifted_v = v .+ abs(minimum(v)) .+ 1
        shifted_axis = axis .+ abs(minimum(v)) .+ 1
    else
        shifted_v = v
        shifted_axis = axis
    end
    dist = fit_mle(Gamma,shifted_v)
    dict = OrderedDict(axis[i] => pdf(dist,shifted_axis[i]) for i in 1:length(axis))
    return ((k, get(dict,k,0)) for k in axis)
end


function continuous_Gamma(v;axis = Recombinase.continuous_axis(v, npoints = 100), kwargs...)
    if minimum(v) <= 0
        shifted_v = v .+ abs(minimum(v)) .+ 1
        shifted_axis = axis .+ abs(minimum(v)) .+ 1
    else
        shifted_v = v
        shifted_axis = axis
    end
    dist = fit_mle(Gamma,shifted_v)
    dict = OrderedDict(axis[i] => pdf(dist,shifted_axis[i]) for i in 1:length(axis))
    return ((k, get(dict,k,0)) for k in axis)
end

const Gamma_dist = Recombinase.Analysis((continuous = continuous_Gamma, discrete = discrete_Gamma))
