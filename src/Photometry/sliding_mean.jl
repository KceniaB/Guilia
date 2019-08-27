function sliding_correction(v,gap,dur;factor=1)
    m = sliding(v,dur*factor)
    r = lag(m,gap*factor,default = NaN)
    #m = Guilia.rolling_mean(v,gap,dur;factor=factor)
    s = (v.-m)./m
end

function sliding(v, n)
    s = fill(1/n, (n,))
    imfilter(v, OffsetArray(s, -n))
end
