function combine_colors(x)
    [c[] for c in x[]]
end

function custom_pallette(;n_colors=8)
    wdg = Widget{:Pallette}(output = Observable{Any}(Recombinase.wong_colors))
    wdg[:List] = Interact.@map([colorpicker() for x in 1:n_colors])
    wdg[:Update] = button("Update colors")
    output = Interact.@map (&wdg[:Update]; combine_colors(wdg[:List]))
    connect!(output,wdg.output)
    @layout! wdg vbox(:Update,vbox(:List[]))
end
