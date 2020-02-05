function separate(t,cond::AbstractArray,var::Symbol)
    if isempty(cond)
        return t
    else
        for condition in cond
            res = separate(t,condition,var)
            t = transform(t,res)
        end
    end
    return t
end

function separate(t,cond::Symbol,var::Symbol)
    conditions = union(columns(t, cond))
    # data = @transform t (
    #            ctrue = cols(cond) == conditions[1] ? cols(var) : NaN,
    #            cfalse = cols(cond) == conditions[1] ? NaN : cols(var),
    #        )
    ctrue = [case == conditions[1] ? value : NaN for (case,value) in rows(t,(cond,var))]
    cfalse = [case == conditions[1] ? NaN : value for (case,value) in rows(t,(cond,var))]
    newname1 = Symbol(string(var)*"_"*string(cond)*"True")
    newname2 = Symbol(string(var)*"_"*string(cond)*"False")
    #data = JuliaDB.rename(data,(:ctrue => newname1,:cfalse => newname2))
    return (newname1 => ctrue, newname2 => cfalse)
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

    ns = Observables.@map sort(collect(colnames(&data)))
    maybens = Observables.@map vcat(Symbol(), &ns)
    binaries = map(take_binaries, data, maybens)
    #binaries = Observables.@map take_binaries(&data, &maybens)
    selection = checkboxes(binaries)
    #wdg[:Selectors] = Observables.@map checkboxes(&binaries)
    largens = map(take_large,data, maybens)
    #largens = Observables.@map take_large(&data, &maybens)
    measure = dropdown(largens)
    #wdg[:Measure] = dropdown(largens)
    separate_b = button(label="Separate!")
    #wdg[:Separate] = button(label="Separate!")

    output = Interact.@map (&separate_b; separate(&data, selection[],measure[]))
    wdg = Widget{:Separator}(OrderedDict(
                                :Selectors =>   selection,
                                :Measure => measure,
                                :Separate => separate_b
                                );
                                output = output)
    @layout! wdg vbox(
                    hbox(:Separate,hskip(1em),:Measure),
                    :Selectors
                    )
    return wdg
end
