import IterTools

_hbox(args...) = Widgets.div(args...; style = Dict("display" => "flex", "flex-direction"=>"row"))
_vbox(args...) = Widgets.div(args...; style = Dict("display" => "flex", "flex-direction"=>"column"))

get_kwargs(; kwargs...) = kwargs
string2kwargs(s::AbstractString) = eval(Meta.parse("get_kwargs($s)"))

const Analysis_list = ["",
    "Cumulative",
    "Density",
    "Hazard",
    "Prediction",
    "PredictionWithAxis",
    "Μ_σ scatter",
    "Gamma",
    "Count",
    "Sum",
    "Delta_means",
    "NormalizedDensity"]

const Analysis_functions = OrderedDict(
    "" => nothing,
    "Cumulative" => Recombinase.cumulative,
    "Density" => Recombinase.density,
    "Hazard" => Recombinase.hazard,
    "Prediction" => Recombinase.prediction,
    "PredictionWithAxis" => Recombinase.prediction(axis = -60:60),
    "Μ_σ scatter" => Guilia.scatter_mu_sd,
    "Gamma" => Guilia.Gamma_dist,
    "Count" => Guilia.count,
    "Sum" => Guilia.summing,
    "Delta_means" => Guilia.Delta_means,
    "NormalizedDensity" => Guilia.NormalizedDensity)

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
function customized_gui(data′, plotters; postprocess = NamedTuple())
    (data′ isa Observables.AbstractObservable) || (data′ = Observable{Any}(data′))
    data = Observables.@map table(&data′, copy = false, presorted = true)
    ns = Observables.@map sort(collect(colnames(&data)))
    maybens = Observables.@map vcat(Symbol(), &ns)
    smallns =  map(take_small, data, maybens)
    xaxis = dropdown(ns,label = "X")
    yaxis = dropdown(maybens,label = "Y")
    an_opt = dropdown(Analysis_list, label = "Analysis")
    ## list of specific arguments per fucntion
    vectorialaxis = offset_window()
    n_bins = spinbox(value = 50)
    BandWidth = spinbox(0.01:0.01:1;value = 0.1)
    smoothness = Guilia.smoothings()
    normalized_axes = offset_window(Start_offset = 0, Stop_offset = 5,step = 0.1)
    factor = dropdown(smallns, label = "Comparing Factor")
    # normalizations_opts = dropdown(normalizations_functions, label = "Normalization method")
    opts = Observables.@map mask(OrderedDict(
        "Density"=>vbox("Number of points",n_bins),
        "NormalizedDensity"=>vbox("Smoothing method",smoothness,"Axes",normalized_axes),
        "PredictionWithAxis" => vectorialaxis,
        "Delta_means" => factor); key = &an_opt)
    ##
    axis_type = dropdown([:automatic, :continuous, :discrete, :vectorial], label = "Axis type")
    error = dropdown(Observables.@map(vcat(Recombinase.automatic, &ns)), label="Error")
    styles = collect(keys(Recombinase.style_dict))
    sort!(styles)
    splitters = [dropdown(smallns, label = string(style)) for style in styles]
    plotter = dropdown(plotters, label = "Plotter")
    ribbon = toggle("Ribbon", value = false)
    btn = button("Plot")
    output = Observable{Any}("Set the dropdown menus and press plot to get started.")
    # plot_kwargs = Widgets.textbox("Insert optional plot attributes")
    typed_attributes = Widgets.textbox("Insert optional plot attributes")
    attributes = plot_attributes_w()
    plot_kwargs = Interact.@map isempty(&typed_attributes) ? &attributes : &attributes * "," * &typed_attributes
    Observables.@map! output begin
        &btn
        select = yaxis[] == Symbol() ? xaxis[] : (xaxis[], yaxis[])
        grps = Dict(key => val[] for (key, val) in zip(styles, splitters) if val[] != Symbol())
        an = Analysis_functions[an_opt[]]
        if an == Analysis_functions["PredictionWithAxis"]
            an = an(axis = vectorialaxis[])
        elseif (an == Analysis_functions["Density"])
            an = an(npoints = n_bins[])
        elseif (an == Analysis_functions["NormalizedDensity"])
            Norm_opts = merge(smoothness[],(axis = normalized_axes[],))
            an = an(;Norm_opts...)
        elseif (an == Analysis_functions["Delta_means"])
            select = (xaxis[], yaxis[],factor[])
        end
        an_inf = isnothing(an) ? nothing : Recombinase.Analysis{axis_type[]}(an)
        args, kwargs = Recombinase.series2D(
                                an_inf,
                                data[], #removed automatic plot when data change
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
            :data => data,
            :xaxis => xaxis,
            :yaxis => yaxis,
            :analysis => an_opt,
            :axis_type => axis_type,
            :error => error,
            :opts => opts,
            :vectorialaxis => vectorialaxis,
            :n_bins => n_bins,
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
                                    hbox(
                                          :xaxis,
                                          :yaxis,
                                          :analysis,
                                          :axis_type,
                                          :error,
                                          :plotter
                                         ),
                                    vskip(1em),
                                    hbox(
                                        vbox(
                                            :ribbon,
                                            :opts,
                                            vskip(1em),
                                            :plot_button,
                                            vbox(:splitters...)
                                            ),
                                        hbox(
                                              hskip(1em),
                                              vbox(output, :typed_attributes),
                                              hskip(1em),
                                              :attributes
                                             )
                                         )
                                   )
end
