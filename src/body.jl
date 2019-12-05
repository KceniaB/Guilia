function mygui(fn, categorical_thrs)
    data = Guilia.carica(fn)
    filters = selectors(data,threshold = categorical_thrs,types = Dict([:MouseID => TableWidgets.categorical, :Box => TableWidgets.categorical]));
    categorizer = categorify_w(filters);
    separator  = separate_w(categorizer);
    viewer = customized_gui(separator, [plot, scatter, groupedbar]);

    components = OrderedDict(
        :filters => filters,
        :editor => hbox(categorizer,separator),
        :viewer => viewer)

    lt = tabulator(components);
    return Widget(components, layout = _ -> lt, output = observe(viewer));
end
##
function mygui_signal(t_name,d_name; thrs = 10)
    t_name isa Observables.AbstractObservable || (t_name = Observable{Any}(t_name))
    d_name isa Observables.AbstractObservable || (d_name = Observable{Any}(d_name))

    data = Guilia.carica(t_name[])
    dic = Guilia.carica(d_name[])
    gross_filters = selectors(data,threshold = thrs,types = Dict([:MouseID => TableWidgets.categorical, :Box => TableWidgets.categorical]));
    signals = Guilia.construct_signal(dic,gross_filters);
    filters = selectors(signals,threshold = thrs,types = Dict([:MouseID => TableWidgets.categorical, :Box => TableWidgets.categorical]));
    categorizer = categorify_w(filters);
    separator  = separate_w(categorizer);
    viewer = customized_gui(separator,[plot, scatter, groupedbar], postprocess = (; Offsets = t -> t / 50))

    components = OrderedDict(
        :trim => gross_filters,
        :signals => signals,
        :filters => filters,
        :editor => hbox(categorizer,separator),
        :viewer => viewer)

    lt = tabulator(components);
    return Widget(components, layout = _ -> lt, output = observe(viewer));
end
##
"""
´launch(;categorical_thrs = 10)´

launch a gui with filters and editor to plot through recombinase.
Use categorical_thrs to determined how many maximum unique value in an array determined if its continouos or categorical
"""
function launch(;categorical_thrs = 10)
    f  = filepicker();
    datagui = Observable{Any}("Load a file")
    saver = Interact.savedialog()
    on(saver) do fn
        savefig(datagui[][],saver[]);
    end
    map!(mygui, datagui, f, categorical_thrs)

    w = Window()
    body!(w, Widgets.div(hbox(hskip(1em), f, hskip(1em), saver), datagui))
    return datagui
end
##
function launch_signal(;categorical_thrs = 10)
    t = filepicker();
    d = filepicker();
    datagui = Observable{Any}("Load a file")
    saver = Interact.savedialog()
    on(saver) do fn
        savefig(datagui[][],saver[]);
    end
    loader = button(label="Load")
    on(loader) do x
         datagui[] = mygui_signal(t,d,thrs = categorical_thrs)
    end
    # datagui = Interact.@map (&loader; mygui_signal(t,d,thrs = categorical_thrs))

    w = Window()
    body!(w,Widgets.div(
                        vbox(
                            hbox(
                                vbox("Table",t),
                                hskip(1em),
                                vbox("Dictionary",d),
                                hskip(1em),
                                vbox(vskip(1em),hbox(loader,hskip(1em),saver))
                                )
                            ,datagui
                            )
                        )
                    )
    return datagui
end
