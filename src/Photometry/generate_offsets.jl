"""
`generate_offsets(cam_dict,session,frame_in;window_s =30,fps = 50)`

given a dictionary `cam_dict` of traces stored in `IndexedTable.table`
calculates an offsetrange centeraround `frame_in`.
The size of the array is define by `± windows_s*fps`.
In case the column Trace is not present return an array of NaNs of the
required size.
"""
function generate_offsets(cam_dict::OrderedDict,session::String,frame_in::Int;window_s =30,fps = 50)
    w = window_s*fps
    to_collect = frame_in - w:frame_in + w
    if session in keys(cam_dict)
        #since offsetrange are usable over any array of matching length it can be set over a general array
        #of legth equal to the camera
        t = collect(1:length(cam_dict[session]))
        if to_collect.start < 0
            to_collect= 1:frame_in + w
        end
        if to_collect.stop > length(t)
            to_collect = frame_in - w:length(t) -5
        end
        return offsetrange(t,frame_in,to_collect)
    else
        t = fill(NaN,400)
        println("Session $(Session) not found in cam_dict")
        return offsetrange(t,200,100:300)
    end
end



"""
`add_offsets(dic::OrderedDict,data::IndexedTables.IndexedTable)`

Widget to apply the function generate_offsets to a `data` table and a matchind dictionary `dic` of traces.
Allignment alternatives are offer among the columns that contain Int values.
"""
function add_offsets(dic::OrderedDict,data::IndexedTables.IndexedTable)
    mask = [eltype(column(data,x)) == Int for x in colnames(data)]
    col_names = colnames(data)[mask]
    t = table(columns(data,colnames(data)[mask]))
    allignment_option = dropdown(collect(colnames(t)),label = " Allign on");
    el1 = node(:div,  "Time window in ± seconds")
    seconds = spinbox(value=30)
    el2 = node(:div,  "Data rate in Hz")
    hertz = spinbox(value= 50)
    output =  Observables.@map @transform data {Offsets = generate_offsets(dic,:Session,cols(&allignment_option);window_s = Int64(&seconds),fps = Int64(&hertz))}
    wdg = Widget(["Allignment" => allignment_option, "Window"=>seconds, "Rate"=>hertz ],output = output)
    @layout! wdg vbox(:Allignment,el1,:Window,el2,:Rate)
end
