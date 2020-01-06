function sum_stuff(c,v; kwargs...)
    t = table(c, v)
    t1 = groupreduce(KahanSum(), t, 1, select=2)
    JuliaDB.select(t1, (1, 2 => value))
end

#########WHY WOULD YOYU DO THAT??###############
function sum_stuff_cont(c,v;npoints = 10, axis = categorize(c,npoints), kwargs...)
    t = table(c, v)
    t1 = groupreduce(KahanSum(), t, 1, select=2)
    JuliaDB.select(t1, (1, 2 => value))
end

const summing = Recombinase.Analysis((continuous = sum_stuff_cont, discrete = sum_stuff))
