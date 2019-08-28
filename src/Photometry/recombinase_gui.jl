import IterTools

_hbox(args...) = Widgets.div(args...; style = Dict("display" => "flex", "flex-direction"=>"row"))
_vbox(args...) = Widgets.div(args...; style = Dict("display" => "flex", "flex-direction"=>"column"))

get_kwargs(; kwargs...) = kwargs
string2kwargs(s::AbstractString) = eval(Meta.parse("get_kwargs($s)"))

const analysis_options_hacked = OrderedDict(
    "" => nothing,
    "Cumulative" => Recombinase.cumulative,
    "Density" => Recombinase.density,
    "Hazard" => Recombinase.hazard,
    "Prediction" => Recombinase.prediction,
    "PredictionWithAxis" => Recombinase.prediction(axis = -60:60))

is_small(col::AbstractArray) = false
is_small(col::AbstractArray{<:Union{Missing, Bool, AbstractString}}) = true

function take_small(t, vec::AbstractVector{Symbol})
    filter(vec) do sym
        sym == Symbol() || is_small(column(t, sym))
    end
end

_tuple(t::Tuple) = t
_tuple(t) = tuple(t)

"""
`gui_signals(data, plotters; postprocess = NamedTuple())`
Create a gui around `data::IndexedTable` given a list of plotting
functions plotters.
## Examples
"""
function gui_signals(data′, plotters; postprocess = NamedTuple())
    (data′ isa Observables.AbstractObservable) || (data′ = Observable{Any}(data′))
    data = Observables.@map table(&data′, copy = false, presorted = true)
    ns = Observables.@map sort(collect(colnames(&data)))
    maybens = Observables.@map vcat(Symbol(), &ns)
    xaxis = dropdown(ns,label = "X")
    yaxis = dropdown(maybens,label = "Y")
    an_opt = dropdown(analysis_options_hacked, label = "Analysis")
    axis_type = dropdown([:automatic, :continuous, :discrete, :vectorial], label = "Axis type")
    error = dropdown(Observables.@map(vcat(Recombinase.automatic, &ns)), label="Error")
    styles = collect(keys(Recombinase.style_dict))
    sort!(styles)
    smallns =  map(take_small, data, maybens)
    splitters = [dropdown(smallns, label = string(style)) for style in styles]
    plotter = dropdown(plotters, label = "Plotter")
    ribbon = toggle("Ribbon", value = false)
    btn = button("Plot")
    output = Observable{Any}("Set the dropdown menus and press plot to get started.")
    # plot_kwargs = Widgets.textbox("Insert optional plot attributes")
    typed_attributes = Widgets.textbox("Insert optional plot attributes")
    attributes = plot_attributes_w()
    plot_kwargs = Interact.@map isempty(&typed_attributes) ? &attributes : &attributes * "," * &typed_attributes
    vectorialaxis = offset_window()
    Observables.@map! output begin
        &btn
        select = yaxis[] == Symbol() ? xaxis[] : (xaxis[], yaxis[])
        grps = Dict(key => val[] for (key, val) in zip(styles, splitters) if val[] != Symbol())
        an = an_opt[]
        an == analysis_options_hacked["PredictionWithAxis"] && (an = an(axis = vectorialaxis[]))
        an_inf = isnothing(an) ? nothing : Recombinase.Analysis{axis_type[]}(an)
        args, kwargs = Recombinase.series2D(
                                an_inf,
                                &data,
                                Recombinase.Group(; grps...);
                                postprocess = postprocess,
                                select = select,
                                error = error[],
                                ribbon = ribbon[]
                               )
        plotter[](args...; kwargs..., string2kwargs(plot_kwargs[])...)
    end
    ui = Widget(
        OrderedDict(
            :vectorialaxis => vectorialaxis,
            :xaxis => xaxis,
            :yaxis => yaxis,
            :analysis => an_opt,
            :axis_type => axis_type,
            :error => error,
            :plotter => plotter,
            :plot_button => btn,
            :ribbon => ribbon,
            :splitters => splitters,
            :typed_attributes => typed_attributes,
            :attributes => attributes,
            :plot_kwargs => plot_kwargs,
        ),
        output = output
    )

    Widgets.@layout! ui Widgets.div(
                                    _hbox(
                                          :xaxis,
                                          :yaxis,
                                          :analysis,
                                          :axis_type,
                                          :error,
                                          :plotter
                                         ),
                                    :ribbon,
                                    :vectorialaxis,
                                    vskip(1em),
                                    :plot_button,
                                    hbox(
                                          vbox(:splitters...),
                                          hskip(1em),
                                          vbox(output, :typed_attributes),
                                          hskip(1em),
                                          :attributes
                                         )
                                   )
end
