"""
`generate_offsets(cam_dict,session,frame_in;window_s =30,fps = 50)`

given a dictionary `cam_dict` of traces stored in `IndexedTable.table`
calculates an offsetrange centeraround `frame_in`.
The size of the array is define by `± windows_s*fps`.
In case the column Trace is not present return an array of NaNs of the
required size.
"""

function generate_offsets(dic,session,frame_in,wdg)
    v = collect(1:length(dic[session]))
    if !wdg[:Time_slice][] & !wdg[:Event_slice][]
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
