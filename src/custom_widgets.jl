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

function smoothings()
    points = spinbox(value = 50)
    width = spinbox(0.01:0.01:1;value = 0.1)
    opts_names = OrderedDict(
        "Number of points" => :npoints,
        "Band width" => :bandwidth)
    opts_vals = OrderedDict(
        "Number of points" => points,
        "Band width" => width)
    opts_list = dropdown(["Band width","Number of points"])
    opts = Observables.@map mask(&opts_vals; key = &opts_list)
    output = Observable{Any}(Dict(:bandwidth => 0.1))
    #output = Interact.@map Dict(Symbol(&opts_list) => opts_vals[&opts_list][])
    Observables.@map! output begin
        &points
        &width
        Dict(opts_names[&opts_list] => opts_vals[&opts_list][])
    end
    smoothing = Widget{:smooth}(
                            OrderedDict(
                                :choice => opts_list,
                                :value => opts_vals,
                                :lay => opts
                            );
                            output = Interact.@map Guilia.namedtuple(&output)
                            )
    Widgets.@layout! smoothing Widgets.div(:choice,:lay)
end

s = smoothings()
s[]
