function separate(t,cond,var)
    conditions = union(column(t, cond))
    data = @transform t (
               ctrue = cols(cond) == conditions[1] ? cols(var) : NaN,
               cfalse = cols(cond) == conditions[1] ? NaN : cols(var),
           )
    newname1 = Symbol(string(var)*"_"*string(cond)*"True")
    newname2 = Symbol(string(var)*"_"*string(cond)*"False")
   data = JuliaDB.rename(data,(:ctrue => newname1,:cfalse => newname2))
   return data
end

function is_binary(col)
    length(union(col)) == 2
end

function take_binaries(t,vec::AbstractVector{Symbol})
    filter(vec) do sym
        col = get(columns(t), sym, ())
        return is_binary(col)
    end
end

function separate_w(data′)
    (data′ isa Observables.AbstractObservable) || (data′ = Observable{Any}(data′))
    data = Observables.@map table(&data′, copy = false, presorted = true)

    wdg = Widget{:Separator}(output = Observable{Any}(data[]))

    ns = Observables.@map sort(collect(colnames(&data)))
    maybens = Observables.@map vcat(Symbol(), &ns)
    binaries = map(take_binaries, data, maybens)
    wdg[:Selectors] = checkboxes(binaries)
    # wdg[:Bool] = togglecontent(wdg[:Selectors])
    largens = map(Guilia.take_large, data, maybens)
    wdg[:Measure] = dropdown(largens)
    wdg[:Separate] = button(label="Separate!")

    output = Interact.@map (&wdg[:Separate]; separate(&data,wdg))
    connect!(output,wdg.output)
    @layout! wdg vbox(
                    hbox(:Separate,hskip(1em),:Measure),
                    :Selectors
                    )
    return wdg
end

function separate(data::IndexedTables.IndexedTable,s::Widget{:Separator})
    if length(s[:Selectors][]) > 0
        for condition in s[:Selectors][]
            data = separate(data,condition,s[:Measure][])
        end
    end
    return data
end
