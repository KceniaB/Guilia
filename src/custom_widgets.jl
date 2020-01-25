function offset_window(;Start_offset = -50, Stop_offset = 50, step = 1)
    window_start = spinbox(value = Start_offset)
    window_stop = spinbox(value = Stop_offset)
    vectorialaxis = Widget{:visualization}(
                                        OrderedDict(
                                            :Start=> window_start,
                                            :Stop => window_stop
                                            );
                                        output = Interact.@map range(&window_start,stop = &window_stop, step = step)
                                        )
    Widgets.@layout! vectorialaxis Widgets.div(
                                            vbox(
                                                vbox("Start",:Start),
                                                vskip(1em),
                                                vbox("Stop",:Stop)
                                                )
                                            )
end
