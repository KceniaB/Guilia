function fit_Gamma(v;axis = Recombinase.discrete_axis(x), kwargs...)

    if minimum(v) <= 0
        shifted_v = v .+ abs(minimum(v)) .+ 1
        shifted_axis = axis .+ abs(minimum(v)) .+ 1
    else
        shifted = v
        shifted_axis = axis
    end

    dist = fit_mle(Gamma,shifted_v)
    dict = OrderedDict(axis[i] => pdf(dist,shifted_axis[i]) for i in 1:lenght(axis))
    #plot(xaxis,pdf(dist,shifted_axis))

    return ((k, get(dict,k,0)) for k in axis)
end

const Gamma_dist = Recombinase.Analysis((continuous = fit_Gamma, discrete = fit_Gamma))
