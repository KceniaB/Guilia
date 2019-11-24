function scatter_mu_sd(v;axis = Recombinase.discrete_axis(v), kwargs...)
    μ = mean(v)
    σ = stderr(v)
    dict = OrderedDict(μ => σ)
end
