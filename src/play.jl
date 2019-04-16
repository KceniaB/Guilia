
w = Window()
f  = filepicker();
body!(w,f)

print(f[])

###
dati = ("/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Stimulations/DRN_Nac_Sert_ChR2/streaksDRN_Nac_Sert_ChR2.jld2");
tab_dat = carica(dati);
###

data = Observable{Any}(table(tab_dat));
# Example dict for selectors a = Dict(:MouseID => TableWidgets.categorical, :Session => TableWidgets.numerical, :altro => TableWidgets.arbitrary)

TableWidgets.categorical
TableWidgets.categorical
TableWidgets.ColumnType

filters = selectors(data);
editor = dataeditor(filters);
viewer = Recombinase.gui(editor, [plot, scatter, groupedbar]);

components = OrderedDict(
    :filters => filters,
    :editor => editor,
    :viewer => viewer)

lt = tabulator(components)

ui = Widget(components, layout = _ -> lt)
w = Window()
body!(w,ui)
##
series2D(editor[])
Interact.@map!

function splintergui(data)
    (data isa Observables.AbstractObservable) || (data = Observable{Any}(data))
    ns = Interact.@map collect(colnames(&data))
    maybens = Interact.@map vcat(Symbol(), &ns)
    xaxis = dropdown(ns,label = "X")
    yaxis = dropdown(maybens,label = "Y")
    an_opt = dropdown(analysis_options, label = "Analysis")
    across = dropdown(ns, label="Across")
    styles = collect(keys(GroupSummaries.style_dict))
    sort!(styles)
    splinters = [dropdown(maybens, label = string(style)) for style in styles]
    plotter = dropdown([plot, scatter, groupedbar], label = "Plotter")
    ribbon = toggle("Ribbon", value = true)
    btn = button("Plot")
    output = Observable{Any}(plot())
    Interact.@map! output begin
        &btn
        select = yaxis[] == Symbol() ? xaxis[] : (xaxis[], yaxis[])
        grps = Dict(key => val[] for (key, val) in zip(styles, splinters) if val[] != Symbol())
        args, kwargs = GroupSummaries.series2D(an_opt[], &data, GroupSummaries.Group(; grps...);
            select = select, across = across[], ribbon = ribbon[])
        plotter[](args...; kwargs...)
    end
    ui = Widget(
        OrderedDict(
            :xaxis => xaxis,
            :yaxis => yaxis,
            :analysis => an_opt,
            :across => across,
            :plotter => plotter,
            :plot_button => btn,
            :ribbon => ribbon,
            :splinters => splinters,
        ),
        output = output
    )
    @layout! ui vbox(hbox(:xaxis, :yaxis, :analysis, :across, :plotter), :ribbon, :plot_button,
        hbox(vbox(:splinters...), output))
end
##
www= splintergui(data);
body!(w,www)
unique(column(data[], :MouseID))
