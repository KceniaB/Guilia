#=
legend position = option
ylims = spin boxes
xlims = spin boxes
figure size = spin boxes
title = string
xlabel = string
ylabel = string
=#
function plot_attributes_w()
    wdg = Widget{:Plot_attributes}(output = Observable{Any}(("title = \"\"")))
    wdg[:Title] = Guilia.text_attribute("title")
    wdg[:Xlabel] = Guilia.text_attribute("xlabel")
    wdg[:Ylabel] = Guilia.text_attribute("ylabel")
    text_output = Interact.@map join((&wdg[:Title], &wdg[:Xlabel], &wdg[:Ylabel]),",")
    # text_output = Interact.@map merge(&wdg[:Title], &wdg[:Xlabel], &wdg[:Ylabel])

    wdg[:Fig_size] = Guilia.twoVals_attribute("size",809,500;default = (809,500))
    wdg[:Xlims] = Guilia.twoVals_attribute("xlims",809,500)
    wdg[:Ylims] = Guilia.twoVals_attribute("ylims",809,500)
    measure_output = Interact.@map join((&wdg[:Fig_size], &wdg[:Xlims], &wdg[:Ylims]),",")
    # measure_output = Interact.@map merge(&wdg[:Fig_size], &wdg[:Xlims], &wdg[:Ylims])

    output = Interact.@map join((&text_output,&measure_output),",")
    connect!(output,wdg.output)
    @layout! wdg vbox(:Title,
                    :Xlabel,
                    :Ylabel,
                    :Fig_size,
                    :Xlims,
                    :Ylims)

    return wdg
end

function text_attribute(nome::String)
    txt = Widgets.textbox("Insert title")
    res = map(txt) do val
        isempty(val) ? "$nome = \"\" " : "$nome = \"$val\""
        #isempty(val) ? Dict(Symbol(nome) => "") : Dict(Symbol(nome) => val)
    end
    # output = Interact.@map Guilia.namedtuple(&res)
    # wdg = Widget{:Text_attribute}(output = output)
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
    #res = Interact.@map &choice ? Dict(Symbol(nome) => (&start,&stop)) : Dict(Symbol(nome) => default)
    # output = Interact.@map Guilia.namedtuple(&res)
    # wdg = Widget{:Size_attribute}(output = output)
    wdg = Widget{:Size_attribute}(output = res)

    wdg[:attribute] = nome
    wdg[:Min_value] = start
    wdg[:Max_value] = stop
    wdg[:Choice] = choice
    @layout! wdg vbox(:attribute,:Choice)
    return wdg
end
