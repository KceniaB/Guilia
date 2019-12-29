"""
`scatter_mu_sd(c, v; axis = Recombinase.vectorial_axis(v), kwargs...)`
Per each category in c calculate mean (x coordinate) and standard deviation (y coordinate) of v
"""
function scatter_mu_sd(c, v; axis = Recombinase.vectorial_axis(v), kwargs...)
    t = table(c, v)
    t1 = groupreduce(Variance(), t, 1, select=2)
    JuliaDB.select(t1, (2 => mean, 2 => std))
end
