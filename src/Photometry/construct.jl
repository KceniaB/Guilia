
function construct_photo(cam, pokes)
    with_offsets = add_offsets(cam,pokes)
    with_traces = Observables.@map load_traces(cam, &with_offsets)
    wdg = Widget(["Offset_t" => with_offsets, "Signal_t"=> with_traces],output = with_traces[])
    @layout! wdg vbox(:Offset_t,:Signal_t)
end
