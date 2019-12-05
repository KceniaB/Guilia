function scatter_mu_sd(v,c; axis = Recombinase.vectorial_axis(v), kwargs...)
    cat = union(c)
    means = []
    vars = []
    for i in cat
        stats = Series(Mean(), Variance())
        fit!(stats,v[occursin.(i,c)])
        push!(means,value(stats)[1])
        push!(vars,value(stats)[2])
    end
    return ((μ,σ) for (μ,σ) in zip(means,vars))
end
