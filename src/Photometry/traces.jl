"""
`collect_traces(cam_dict,session,frame_in,trace;window_s =30,fps = 50)`

given a dictionary `cam_dict` of traces stored in `IndexedTable.table`
collect a slice in the key `session` in column `trace` center
around `frame_in`. The size of the array is define by `± windows_s*fps`.
In case the column Trace is not present return an array of NaNs of the
required size.
"""
function collect_traces(dic::OrderedDict,session::String,trace::Symbol)
    if session in keys(dic)
        if trace in colnames(dic[session])
            t = column(dic[session],trace)
            return t
        else
            return fill(NaN,length(dic[session]))
        end
    else
        println("Session $(Session) not found in dic")
        return fill(NaN,length(dic[session]))
    end
end

function take_sig(dic_session)
    @with dic_session :Signal
end


function process_trace(dic,session,wdg)
    v = collect_traces(dic,session,wdg[:Signal][])
    if isempty(findall(!isnan,v))
        return v
    else
        if !wdg[:Sliding_norm][] & !wdg[:Regression][]
            return v
        elseif wdg[:Sliding_norm][]
            s = Guilia.sliding_correction(v,wdg[:Gap][],wdg[:Norm_Dur][],factor=wdg[:Rate][])
        else
            s = v
        end
        if wdg[:Regression][]
            r = collect_traces(dic,session,wdg[:Reference][])
            if wdg[:Sliding_norm][]
                r = Guilia.sliding_correction(r,wdg[:Gap][],wdg[:Norm_Dur][],factor=wdg[:Rate][])
            end
            s = regress_trace(s,r)
        end
        return s
    end
end


"""
`extract_traces_w`
"""
function extract_traces_w(dic, t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))
    #dic isa Observables.AbstractObservable || (dic = Observable{Any}(dic))

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

    output = Interact.@map (&wdg[:Collect_Traces];extract_traces(wdg,&t,dic))
    connect!(output,wdg.output)

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

"""
`extract_traces`
"""
function extract_traces(wdg,t,dic)
    collection = @with t union(:Session)
    for ses in collection
        dic[ses] = @transform_vec dic[ses] {Signal = Guilia.process_trace(dic,ses,wdg)}
    end
    prov = JuliaDBMeta.@groupby t :Session {Signal = Guilia.take_sig(dic[_.key.Session])}
    return join(t,prov,lkey=:Session,rkey=:Session)
end
