function construct_photo(dic, t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_signals}(output = Observable{Any}(t[]))
    wdg[:Collect] = button(label = "Collect Trace")
    mask = [eltype(column(t[],x)) == Int for x in colnames(t[])]
    col_names = collect(colnames(t[])[mask])
    wdg[:Allignment] = dropdown(col_names)
    el1 = node(:div,  "Data rate in Hz")
    wdg[:Rate] = spinbox(value=50)
    el2 = node(:div,  "Time window in ± seconds")
    wdg[:Slice] = spinbox(value=30)

    wdg[:Signal] = dropdown(dic["trace_list"],label = " Select Trace")

    el3 = node(:div, "Sliding Normalisation")
    wdg[:Slide_in] = spinbox(value = 5)
    wdg[:Slide_out] = spinbox(value = 10)
    wdg[:Sliding_norm] = togglecontent(vbox(wdg[:Slide_in],wdg[:Slide_out]),value = true)

    el4 = node(:div, "Regress Signal")

    wdg[:Reference] = dropdown(dic["trace_list"],label = " Select Reference")
    wdg[:Local] = checkbox(value=false,"Local regression?")
    wdg[:Reg_interval] = spinbox(1)
    appearance = vbox(wdg[:Reference],hbox(wdg[:Local],wdg[:Reg_interval]))
    wdg[:Regression] = togglecontent(appearance,value = false)


    on(wdg[:Collect]) do x
        New = prepare_trace(dic,t[],wdg)
        wdg.output[] = New[]
    end
    @layout! wdg vbox(:Collect,:Allignment,el1,:Rate,el2,:Slice, :Signal,
    el3,:Sliding_norm,#:Slide_in,:Slide_out,
    el4,:Regression,:Regressor)
    wdg
end




function prepare_trace(dic,t,wdg)
     trace = Observables.@map @apply t begin
        @transform {Offsets = Recombinase.offsetrange(fill(NaN,length(dic[:Session])),cols(&wdg[:Allignment]))}
        @transform {Signal = compute_trace(dic,:Session,:Offsets,wdg)}
    end
    return trace
end


function compute_trace(dic,session,offset,wdg)
    s = collect_traces(dic,session,wdg[:Signal][])
    if isempty(findall(!isnan,s))
        return s
    else
        if wdg[:Sliding_norm][]
            s = sliding_f0(s,offset,wdg[:Slide_in][],wdg[:Slide_out][])
        end
        if wdg[:Regression][]
            r = collect_traces(dic,session,wdg[:Reference][])
            if wdg[:Sliding_norm][]
                r = sliding_f0(r,offset,wdg[:Slide_in][],wdg[:Slide_out][])
            end
            s = regress_trace(s,r)
        end
        return s
    end
end
