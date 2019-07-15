function sliding_f0(v,offset,mean_in::Int,mean_out::Int;to_do=true)
    if to_do
        mean_range = mean_in-mean_out:mean_in
         f0 = value(fit!(OnlineStats.Mean(),v[offset][mean_range]))
         normed = (v.-f0)./f0
         return normed
    else
        normed = return v
    end
end

function sliding_correction(v,gap,dur;factor=1)
    m = sliding(v,dur*factor)
    r = lag(m,gap*factor,default = NaN)
    #m = Guilia.rolling_mean(v,gap,dur;factor=factor)
    s = v.-m
end

function sliding(v, n)
    s = fill(1/n, (n,))
    imfilter(v, OffsetArray(s, -n))
end

function rolling_mean(v,gap,dur;factor=1)
    true_gap = gap*factor
    true_dur = dur*factor
    sliding_start = (true_gap+true_dur)
    rolling = repeat([NaN],sliding_start)
    m = mean(v[1:true_dur+1])
    push!(rolling,m)
    for x in v[true_dur+1:end-true_gap-1]
        n_m = (m*(sliding_start-1)+x)/sliding_start
        push!(rolling, n_m)
        m = n_m
    end
    return rolling
end
