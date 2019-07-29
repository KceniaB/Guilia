function extract_traces(dic, t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_traces}(output = Observable{Any}(t[]))

    wdg[:Collect_Traces] = button(label = "Collect Traces")
    wdg[:Signal] = dropdown(dic["trace_list"],label = " Select Trace")
    wdg[:Rate] = spinbox(value=50)
    mask_string = [eltype(column(t[],x)) == String for x in colnames(t[])]
    wdg[:Match] =  dropdown(collect(colnames(t[])[mask_string]))


    wdg[:Gap] = spinbox(value = 5)
    wdg[:Norm_Dur] = spinbox(value = 10)
    appearance_norm = vbox("Gap in sec",wdg[:Gap],"Duration in sec",wdg[:Norm_Dur])
    wdg[:Sliding_norm] = togglecontent(appearance_norm,value = true)

    wdg[:Reference] = dropdown(dic["trace_list"],label = " Select Reference")
    wdg[:Local] = checkbox(value=false,"Local regression?")
    wdg[:Reg_interval] = spinbox(1)
    appearance_reg = vbox(wdg[:Reference],hbox(wdg[:Local],wdg[:Reg_interval]))
    wdg[:Regression] = togglecontent(appearance_reg,value = false)

    on(wdg[:Collect_Traces]) do x
        collection = @with t[] union(:Session)
        for ses in collection
            dic[ses] = @transform_vec dic[ses] {Signal = Guilia.process_trace(dic,ses,wdg)}
        end
        prov = JuliaDBMeta.@groupby t[] :Session {Signal = Guilia.take_sig(dic[_.key.Session])}
        t[] = join(t[],prov,lkey=:Session,rkey=:Session)
        wdg.output = t
    end
    layout_trace = vbox(
                        wdg[:Collect_Traces],
                        hbox(
                            wdg[:Signal],
                            vbox(
                                "Data Rate in Hz",
                                wdg[:Rate]
                                ),
                            vbox(
                                "Connect by",
                                wdg[:Match]
                                )
                            )
                        )

    layout_adjustment = vbox(
                        "Sliding Normalization",
                        wdg[:Sliding_norm],
                        "Regress signal",
                        wdg[:Regression],
                        wdg[:Regressor]
                        )

    @layout! wdg vbox(layout_trace,vskip(1em),layout_adjustment)
end

function generate_offsets(dic,t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_offsets}(output = Observable{Any}(t[]))

    wdg[:Shift] = button(label = "Adjust Offset")
    mask = [eltype(column(t[],x)) == Int for x in colnames(t[])]
    col_names = collect(colnames(t[])[mask])
    wdg[:Allignment] = dropdown(col_names)

    wdg[:Start_event] =  dropdown(col_names)
    wdg[:Stop_event] =  dropdown(col_names)
    events_layout = hbox(vbox("Start at previous",wdg[:Start_event]),vbox("Stop at next",wdg[:Stop_event]))
    wdg[:Event_slice] =  togglecontent(events_layout, value = true)

    wdg[:Slice_sec] = spinbox(value=30)
    allignment_layout = vbox("Time window in ± seconds", wdg[:Slice_sec])
    wdg[:Time_slice] = togglecontent(allignment_layout, value = false)


    on(wdg[:Shift]) do x
        allign_on = wdg[:Allignment][]
        if wdg[:Event_slice][]
            prov = @groupby t[] :Session {Length_data = length(dic[_.key.Session])}
            t[] = join(t[],prov,lkey=:Session,rkey=:Session)
            start_event = wdg[:Start_event][]
            stop_event = wdg[:Stop_event][]
            t[] = @apply t[] (:Session) flatten = true begin
                @transform_vec {Offsets = Guilia.events_offsets(:Length_data[1],cols(allign_on),cols(start_event),cols(stop_event),wdg)}
            end
        elseif wdg[:Time_slice][]
            t[] = @apply t[] @transform {Offsets = time_offsets(length(dic[:Session]),cols(allign_on),wdg)}
        else
            t[] = @transform t[] {Offsets = Recombinase.offsetrange(collect(1:length(dic[:Session])),cols(allign_on))}
        end
        wdg.output = t
    end

    @layout! wdg vbox(
                    :Shift,
                    "Allign on",
                    :Allignment,
                    "Slicing Type",
                    hbox(
                        :Event_slice,
                        "Events slicing"
                        ),
                    hbox(
                        :Time_slice,
                        "Time slicing"
                        )
                    )
end

function construct_signal(dic,t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_signals}(output = Observable{Any}(t[]))

    wdg[:Traces] = Observables.@map traces_extraction(cam,&t)
    wdg[:Offsets] = Observables.@map generate_offsets(cam,&t)

    connect!(wdg[:Offsets],wdg.output)

    @layout! wdg vbox(
                    :Traces,
                    :Offsets
                    )

end
