function sliding_mean(data::IndexedTables.IndexedTable,mean_in::Int64,mean_out::Int64)
    mean_range = mean_in-mean_out:mean_in
    t = @apply data begin
        @transform  {sliding_mean = value(fit!(OnlineStats.Mean(),(:Signal[:Offsets])[mean_range]))}
        @transform  {sliding_normed = (:Signal .- :sliding_mean)./:sliding_mean}
    end
    return @with t :sliding_normed
end
