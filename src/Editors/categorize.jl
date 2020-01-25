function is_large(col)
    !(col isa StringArray || col isa AbstractArray{Bool} || col == Tuple{}())
end

function take_large(t,vec::AbstractVector{Symbol})
    filter(vec) do sym
        col = get(columns(t), sym, ())
        return is_large(col)
    end
end

"""
´binner´
"""
function binner(col;kwargs...)
    bins = spinbox(value = 3)
    check = togglecontent(bins;label = string(col), kwargs...)
    output = Interact.@map (status = &check, name = col, bins = &bins)

    wdg = Widget{:Binner}(OrderedDict(:ToDo => check, :Name => col,:Bins => bins),output = output)

    @layout! wdg vbox(:ToDo)
end

"""
`categorify_w`
"""
function categorify_w(data′)
    (data′ isa Observables.AbstractObservable) || (data′ = Observable{Any}(data′))
    data = Observables.@map table(&data′, copy = false, presorted = true)

    wdg = Widget{:Categorize}(output = Observable{Any}(data[]))

    ns = Observables.@map sort(collect(colnames(&data)))
    maybens = Observables.@map vcat(Symbol(), &ns)
    largens = map(Guilia.take_large, data, maybens)
    cols = [Guilia.binner(n) for n in largens[]]
    paddeds = map(cols) do col
        CSSUtil.pad(10px, col)
    end
    wdg[:Selectors] = cols #paddeds
    wdg[:Categorize] = button(label="Categorize!")

    output = Interact.@map (&wdg[:Categorize]; categorize(&data,&wdg[:Selectors]))
    connect!(output,wdg.output)
    @layout! wdg vbox(:Categorize,
                    Widgets.div(paddeds...,
                        style=Dict(
                            "display" => "flex",
                            "flex-flow" => "row wrap"
                            )
                        )
                    )
    return wdg
end

"""
`categorize`
"""
function custom_cut(v::AbstractArray,nbins)
    f = [ismissing(x) ? NaN : x for x in v]
    filtered = f[.!(isnan.(f))]
    step = 1/nbins
    quantiles = tuple([x*step for x in 1:nbins]...)
    q = quantile(filtered,quantiles)
    category =[findfirst(x .<= q) for x in f]
    nan_category = [x .== nothing ? NaN : x for x in category]
    bins = CategoricalArray(string.(nan_category))
end

function rename_cat(v)
    string(extrema(union(v)))
end

function categorize(v::AbstractArray,nbins)
    cat_v = custom_cut(v,nbins)
    res = table((v = v, bin = cat_v))
    dic = OrderedDict(JuliaDB.groupby(Guilia.rename_cat,res, :bin, select = v))
    return [x*dic[x] for x in cat_v]
end

function categorize(data::IndexedTables.IndexedTable,binner::NamedTuple)
    new_name = Symbol(string(binner.name)*"_cat")
    original = JuliaDB.select(data,binner.name)
    v = categorize(original,binner.bins)
    return JuliaDB.pushcol(data,new_name,v)
end

function categorize(data::IndexedTables.IndexedTable,binner::Widget{:Binner})
    categorize(data,binner[])
end

function categorize(data::IndexedTables.IndexedTable,binner::AbstractVector{Widget{:Binner,Any}})
    for col in binner
        if col[].status
            data = categorize(data,col)
        # data = setcol(data,col[].name,categorize(data,col))
        # data = JuliaDB.pushcol(data,col[].name,categorize(data,col))
        end
    end
    return data
end
