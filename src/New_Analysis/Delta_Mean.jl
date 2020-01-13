"""
`Delta_mean(c,v)`
compute mean and sd of v according to the categorical vector c
"""

function discrete_Delta_means(x, y;factor = Bool(length(x)), axis = Recombinase.discrete_axis(x), method = nothing, kwargs...)
    t0 = table((factor = factor,x = x,y = y))
    factor_cats = unique(JuliaDB.select(t0,:factor))
    factorsize = length(factor_cats)
    if factorsize < 2
        println("impossible operation factoring variable has less than 2 categories")
        return nothing
    end
    if factorsize == 2
        check = tryparse(Bool,factor[1])
        if !isnothing(check)
            factor =  parse.(Bool,factor)
        end
    elseif factorsize > 2
        if method == :Etrema
            t0 = @filter t (:factor == factor_cats[1]) || (:factor == factor_cats[end])
        end
    end
    t1 = groupreduce(Mean(),t0,(:factor,:x);select = :y)
    t1 = sort(t1,:factor)
    t2 = JuliaDB.select(t1,(:factor,:x,:Mean=> value))
    t3 = @groupby t2 :x flatten = true {y = diff(:Mean)}
    JuliaDB.select(t3,(1,2))
end

const Delta_means = Recombinase.Analysis((discrete = discrete_Delta_means,))
