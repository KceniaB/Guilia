"""
`collect_traces(cam_dict,session,frame_in,trace;window_s =30,fps = 50)`

given a dictionary `cam_dict` of traces stored in `IndexedTable.table`
collect a slice in the key `session` in column `trace` center
around `frame_in`. The size of the array is define by `± windows_s*fps`.
In case the column Trace is not present return an array of NaNs of the
required size.
"""
function collect_traces(cam_dict::OrderedDict,session::String,trace::Symbol)
    if session in keys(cam_dict)
        if trace in colnames(cam_dict[session])
            t = column(cam_dict[session],trace)
            return t
        else
            return fill(NaN,length(cam[session]))
        end
    else
        println("Session $(Session) not found in cam_dict")
        return fill(NaN,length(cam[session]))
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
