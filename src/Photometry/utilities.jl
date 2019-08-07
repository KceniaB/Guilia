function  put_in_columns(args...)
    cols = (Widgets.div(className="column", arg) for arg in args)
    return Widgets.div(className = "columns", cols...)
end

function offset_window(Start_offset = -50; Stop_offset = 50)
    window_start = spinbox(value = Start_offset)
    window_stop = spinbox(value = Stop_offset)
    vectorialaxis = Widget{:visualization}(
                                        OrderedDict(
                                            :Start=> window_start,
                                            :Stop => window_stop
                                            );
                                        output = Interact.@map range(&window_start,stop = &window_stop)
                                        )
    Widgets.@layout! vectorialaxis Widgets.div(
                                            _hbox(
                                                _vbox("Start",:Start),
                                                _vbox("Stop",:Stop)
                                                )
                                            )
end
"""
´rescale´
rescale(t::IndexedTables.IndexedTable)

given a table of recombinase analysis result for photometry reshift the data to 0 on the center of the offset
"""
function rescale(t)
    @apply t :g flatten = true begin
        @transform {pos = :x == 0}
        @transform_vec {val = :y .- :y[:pos]}
    end
end
