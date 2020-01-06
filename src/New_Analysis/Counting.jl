function count_stuff(x;axis = Recombinase.discrete_axis(x), kwargs...)
    #need to return an iterator
    c = countmap(x) #count the occurence of values in a Dict
    # uses the axes as key to read the value in the Dict
    return ((k, get(c,k,0)) for k in axis)
end

function count_stuff_cont(x;axis = Recombinase.continuous_axis(x), kwargs...)
    #need to return an iterator
    conv = categorize(x,5)
    c = countmap(conv) #count the occurence of values in a Dict
    # uses the axes as key to read the value in the Dict
    return ((k, get(c,k,0)) for k in sort(unique(conv)))
end

const count = Recombinase.Analysis((continuous = count_stuff_cont, discrete = count_stuff))
