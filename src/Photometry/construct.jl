function construct_photo2(dic, t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_signals}(output = Observable{Any}(t[]))
    wdg[:Collect] = button(label = "Collect Trace")
    mask = [eltype(column(pokes,x)) == Int for x in colnames(pokes)]
    col_names = collect(colnames(pokes)[mask])
    wdg[:Allignment] = dropdown(col_names)
    el1 = node(:div,  "Data rate in Hz")
    wdg[:Rate] = spinbox(value=50)
    el2 = node(:div,  "Time window in ± seconds")
    wdg[:Slice] = spinbox(value=30)

    wdg[:Signal] = dropdown(dic["trace_list"],label = " Select Trace")
    wdg[:Reference] = dropdown(dic["trace_list"],label = " Select Reference")

    el3 = node(:div, "Sliding Normalisation")
    wdg[:Sliding_norm] = toggle(value=true)
    wdg[:Slide_in] = spinbox(value = 5)
    wdg[:Slide_out] = spinbox(value = 10)

    on(wdg[:Collect]) do x
        wdg.output[] = Observables.@map @apply t[] begin
            @transform {Offsets = Recombinase.offsetrange(fill(NaN,length(dic[:Session])),cols(&wdg[:Allignment]))}
            @transform  {Signal = collect_traces(dic,:Session,^(&wdg[:Signal]))}
            @transform  {Signal = sliding_f0(:Signal,:Offsets, -&wdg[:Slide_in], &wdg[:Slide_out]; to_do=&wdg[:Sliding_norm])}
        end
    end
    @layout! wdg vbox(:Collect,:Allignment,el1,:Rate,el2,:Slice, hbox(:Signal,:Reference),el3,:Sliding_norm,:Slide_in,:Slide_out)
    wdg
end
