function carica_tab(s::String)
    table(Guilia.carica(s))
end

function mygui(fn, categorical_thrs)
    data = Guilia.carica(fn)
    filters = selectors(data,threshold = categorical_thrs);
    editor = dataeditor(filters);
    viewer = Recombinase.gui(editor, [plot, scatter, groupedbar]);

    components = OrderedDict(
        :filters => filters,
        :editor => editor,
        :viewer => viewer)

    lt = tabulator(components);
    return Widget(components, layout = _ -> lt, output = observe(viewer));
end

##
function launch(;categorical_thrs = 10)
    f  = filepicker();
    datagui = Observable{Any}("Load a file")
    saver = Interact.savedialog()
    on(saver) do fn
        savefig(datagui[][],saver[]);
    end
    map!(mygui, datagui, f, categorical_thrs)

    w = Window()
    body!(w, Widgets.div(hbox(f, saver), datagui))
end
