function construct_photo(dic, t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_signals}(output = Observable{Any}(t[]))
    wdg[:Collect] = button(label = "Collect Trace")
    wdg[:Signal] = dropdown(dic["trace_list"],label = " Select Trace")
    wdg[:Rate] = spinbox(value=50)
    mask_string = [eltype(column(t[],x)) == String for x in colnames(t[])]
    wdg[:Match] =  dropdown(collect(colnames(t[])[mask_string]))
    appearance_setting = hbox(wdg[:Signal],vbox("Data Rate in Hz",wdg[:Rate]),vbox("Connect by",wdg[:Match]))

    wdg[:Gap] = spinbox(value = 5)
    wdg[:Norm_Dur] = spinbox(value = 10)
    wdg[:Sliding_norm] = togglecontent(vbox("Gap in sec",wdg[:Gap],"Duration in sec",wdg[:Norm_Dur]),value = true)


    wdg[:Reference] = dropdown(dic["trace_list"],label = " Select Reference")
    wdg[:Local] = checkbox(value=false,"Local regression?")
    wdg[:Reg_interval] = spinbox(1)
    appearance = vbox(wdg[:Reference],hbox(wdg[:Local],wdg[:Reg_interval]))
    wdg[:Regression] = togglecontent(appearance,value = false)

    on(wdg[:Collect]) do x
        trace = @transform t[] {Signal = Guilia.compute_trace(dic,:Session,wdg)}
        wdg.output[] = trace
    end

    wdg[:Shift] = button(label = "Adjust Offset")
    mask = [eltype(column(t[],x)) == Int for x in colnames(t[])]
    col_names = collect(colnames(t[])[mask])
    wdg[:Allignment] = dropdown(col_names)
    wdg[:Slice_sec] = spinbox(value=30)
    allignment_layout = vbox("Time window in ± seconds", wdg[:Slice_sec])
    el3 = node(:div, "Slicing type")
    wdg[:Time_slice] = togglecontent(allignment_layout, value = true)

    wdg[:Start_event] =  dropdown(col_names)
    wdg[:Stop_event] =  dropdown(col_names)
    events_layout = hbox(vbox("Start at previous",wdg[:Start_event]),vbox("Stop at next",wdg[:Stop_event]))
    wdg[:Event_slice] =  togglecontent(events_layout, value = false)


    on(wdg[:Shift]) do x
        New =  @transform wdg[] {Offsets = generate_offsets(dic,:Session,cols(wdg[:Allignment][]),wdg)}
        wdg.output[] = New
    end



    @layout! wdg vbox(:Collect,appearance_setting,
    "Sliding Normalization",:Sliding_norm,
    "Regress signal",:Regression,:Regressor,
    :Shift,"Allign on",:Allignment,"Slicing Type",
    hbox(:Time_slice,"Time slicing"),hbox(:Event_slice,"Events slicing"))
    wdg
end




function prepare_trace(dic,t,wdg)
     trace = @apply t begin
         #@transform  {Offsets = generate_offsets(dic,:Session,cols(&wdg[:Allignment]),wdg)}
         #(cols(wdg[:Match][])) flatten = true
         #@transform {Offsets = Recombinase.offsetrange(fill(NaN,length(dic[:Session])),cols(&wdg[:Allignment]))}
         @transform {Signal = compute_trace(dic,:Session,wdg)}
    end
    return trace
end


function compute_trace(dic,session,wdg)
    s = collect_traces(dic,session,wdg[:Signal][])
    if isempty(findall(!isnan,s))
        return s
    else
        if wdg[:Sliding_norm][]
            s = sliding_correction(s,wdg[:Gap][],wdg[:Norm_Dur][],factor=wdg[:Rate][])
            # s = sliding_f0(s,offset,wdg[:Gap][],wdg[:Norm_Dur][])
        end
        if wdg[:Regression][]
            r = collect_traces(dic,session,wdg[:Reference][])
            if wdg[:Sliding_norm][]
                r = sliding_correction(r,wdg[:Gap][],wdg[:Norm_Dur][],factor=wdg[:Rate][])
                # r = sliding_f0(r,offset,wdg[:Gap][],wdg[:Norm_Dur][])
            end
            s = regress_trace(s,r)
        end
        return s
    end
end
