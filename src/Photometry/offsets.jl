"""
`generate_offsets(cam_dict,session,frame_in;window_s =30,fps = 50)`

given a dictionary `cam_dict` of traces stored in `IndexedTable.table`
calculates an offsetrange centeraround `frame_in`.
The size of the array is define by `± windows_s*fps`.
In case the column Trace is not present return an array of NaNs of the
required size.
"""

function time_offsets(dimension,frame_in,wdg)
    v = collect(1:dimension)
    if !wdg[:Time_slice][]
        o = Recombinase.offsetrange(v,frame_in)
        return o
    elseif wdg[:Time_slice][]
        span = wdg[:Slice_sec][]*wdg[:Rate][]
        to_collect = frame_in - span:frame_in + span
        if to_collect.start <= 0
            to_collect= 1:frame_in + span
        end
        if to_collect.stop > length(v)
            to_collect = frame_in - span:length(v) -5
        end
        o = Recombinase.offsetrange(v,frame_in,to_collect)
        return o
    end
end



function events_offsets(dimension,frame_in,start_event,stop_event,rate)
    # this is run per session
    v = collect(1:dimension)
    if ismissing(frame_in)
        return
    else
        #the first in is defined as 1 sec before the first event
        #the last in is defined as 1 sec after the last event
        idxs = table((
        Center = frame_in,
        Starts = lag(start_event,default = stop_event[1]-1*rate),
        Stops = lead(stop_event,default = start_event[end]+1*rate)
        ))
        idxs = @apply idxs begin
            @transform {Ranges = range(:Starts,stop = :Stops)}
            @transform {Offsets = Recombinase.offsetrange(v,:Center,:Ranges)}
        end
        return column(idxs, :Offsets)
    end
end

"""
`generate_offsets_w`
"""
function generate_offsets_w(dic,t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))

    wdg = Widget{:Add_offsets}(output = Observable{Any}(t[]))

    wdg[:Shift] = button(label = "Adjust Offset")
    mask = [eltype(column(t[],x)) == Int for x in colnames(t[])]
    col_names = collect(colnames(t[])[mask])
    wdg[:Allignment] = dropdown(col_names)

    wdg[:Start_event] =  dropdown(col_names)
    wdg[:Stop_event] =  dropdown(col_names)
    wdg[:Rate] = spinbox(value=50)
    events_layout = hbox(vbox("Start at previous",wdg[:Start_event]),vbox("Stop at next",wdg[:Stop_event]),vbox("Rate",wdg[:Rate]))
    wdg[:Event_slice] =  togglecontent(events_layout, value = false)

    wdg[:Slice_sec] = spinbox(value=30)
    allignment_layout = vbox("Time window in ± seconds", wdg[:Slice_sec])
    wdg[:Time_slice] = togglecontent(allignment_layout, value = false)

    output = Interact.@map (&wdg[:Shift];generate_offsets(wdg,&t,dic))
    connect!(output,wdg.output)

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
    return wdg
end


"""
`generate_offsets`
"""
function generate_offsets(wdg,t,dic)
    allign_on = wdg[:Allignment][]
    rate = wdg[:Rate][]
    if wdg[:Event_slice][]
        prov = @groupby t :Session {Length_data = length(dic[_.key.Session])}
        t = join(t,prov,lkey=:Session,rkey=:Session)
        start_event = wdg[:Start_event][]
        stop_event = wdg[:Stop_event][]
        t = @apply t (:Session) flatten = true begin
            @where !ismissing(cols(allign_on))
            @transform_vec {Starts = lag(cols(start_event),default = cols(stop_event)[1]-1*rate)}
            @transform_vec {Stops = lead(cols(stop_event),default = cols(start_event)[end]+1*rate)}
            @transform {Ranges = range(:Starts,step = 1,stop = :Stops)}
            @transform {Offsets = Recombinase.offsetrange(collect(range(1,stop = :Length_data[1])),cols(allign_on),:Ranges)}
            #@transform_vec {Offsets = Guilia.events_offsets(:Length_data[1],cols(allign_on),cols(start_event),cols(stop_event),rate)}
        end
    elseif wdg[:Time_slice][]
        t = @apply t @transform {Offsets = time_offsets(length(dic[:Session]),cols(allign_on),wdg)}
    else
        t = @transform t {Offsets = Recombinase.offsetrange(collect(1:length(dic[:Session])),cols(allign_on))}
    end
    return t
end
