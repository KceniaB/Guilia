module Guilia

using Reexport
@reexport using TableWidgets
@reexport using Interact
@reexport using Blink
@reexport using ProcessPhotometry
using Recombinase: offsetrange


include("body.jl")
include("loading.jl")
include(joinpath("Photometry","generate_offsets.jl"))
include(joinpath("Photometry","combine_photometry.jl"))
include(joinpath("Photometry","construct.jl"))


 export launch
 export carica
 export generate_offsets, add_offsets
 export collect_traces, load_traces
 export construct_photo

end
