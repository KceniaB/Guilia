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
