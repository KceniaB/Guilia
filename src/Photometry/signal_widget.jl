"""
´construct_signal´
"""
function construct_signal(dic,t)
    t isa Observables.AbstractObservable || (t = Observable{Any}(t))
    wdg = Widget{:Add_offsets}(output = Observable{Any}(t[]))

    wdg[:Traces] = Guilia.extract_traces_w(dic, t);
    wdg[:Offsets] = Guilia.generate_offsets_w(dic,wdg[:Traces]);#tracce);

    connect!(wdg[:Offsets],wdg.output)

    @layout! wdg vbox(
                    :Traces,
                    :Offsets
                    )

end
