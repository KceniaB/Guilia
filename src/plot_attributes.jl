function plot_attributes_w()
    wdg = Widget{:Plot_attributes}(output = Observable{Any}(("tick_orientation = :out")))
    wdg[:Title] = Guilia.text_attribute("title")
    wdg[:Xlabel] = Guilia.text_attribute("xlabel")
    wdg[:Ylabel] = Guilia.text_attribute("ylabel")
    text_output = Interact.@map join((&wdg[:Title], &wdg[:Xlabel], &wdg[:Ylabel]),",")

    wdg[:Fig_size] = Guilia.twoVals_attribute("size",809,500;default = (809,500))
    wdg[:Xlims] = Guilia.twoVals_attribute("xlims",0,20)
    wdg[:Ylims] = Guilia.twoVals_attribute("ylims",0,20)
    measure_output = Interact.@map join((&wdg[:Fig_size], &wdg[:Xlims], &wdg[:Ylims]),",")

    wdg[:Tick_dir] = Guilia.optional_attributes("tick_orientation",[:out,:in])
    wdg[:Grid] = Guilia.optional_attributes("grid",[:all,:none,:x,:y])
    wdg[:Legend] = Guilia.optional_attributes("legend",[:topleft,:topright,:bottomleft,:bottomright])
    optional_output = Interact.@map join((&wdg[:Tick_dir], &wdg[:Grid],&wdg[:Legend]),",")

    output = Interact.@map join((&text_output,&measure_output,&optional_output),",")
    connect!(output,wdg.output)
    @layout! wdg hbox(
                    vbox(
                        :Title,
                        :Xlabel,
                        :Ylabel,
                        :Fig_size,
                        :Xlims,
                        :Ylims
                        ),
                        hskip(1em),
                    vbox(
                        :Tick_dir,
                        vskip(1em),
                        :Grid,
                        vskip(1em),
                        :Legend
                        )
                    )

    return wdg
end

function text_attribute(nome::String)
    txt = Widgets.textbox("Insert title")
    res = map(txt) do val
        isempty(val) ? "$nome = \"\" " : "$nome = \"$val\""
    end
    wdg = Widget{:Size_attribute}(output = res)

    wdg[:attribute] = nome
    wdg[:value] = txt
    @layout! wdg vbox(:attribute,:value)
    return wdg
end

function twoVals_attribute(nome::String, first_val, second_val; default = ":auto")
    start = Widgets.spinbox(value = first_val,label = "1st")
    stop = Widgets.spinbox(value = second_val,label = "2nd")
    choice = togglecontent(vbox(start,stop))
    res = Interact.@map &choice ? ("$nome = ($(&start),$(&stop))") : ("$nome = ($default)")
    wdg = Widget{:Size_attribute}(output = res)

    wdg[:attribute] = nome
    wdg[:Min_value] = start
    wdg[:Max_value] = stop
    wdg[:Choice] = choice
    @layout! wdg vbox(:attribute,:Choice)
    return wdg
end

function optional_attributes(nome::String, v::AbstractVector{Symbol})
    opts = opts = radiobuttons(v,label = "$nome")
    res = Interact.@map "$nome = :$(&opts)"
    wdg = Widget{:Option_attribute}(output = res)

    wdg[:attribute] = nome
    wdg[:Choice] = opts
    @layout! wdg vbox(:Choice)
end
