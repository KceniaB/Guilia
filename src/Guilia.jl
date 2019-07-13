module Guilia

using Reexport
@reexport using TableWidgets
@reexport using Interact
@reexport using Blink
@reexport using ProcessPhotometry
@reexport using OnlineStats
@reexport using OffsetArrays
using Observables
using Recombinase: offsetrange
import Observables: AbstractObservable

include("body.jl")
include("loading.jl")
include(joinpath("Photometry","generate_offsets.jl"))
include(joinpath("Photometry","combine_photometry.jl"))
include(joinpath("Photometry","sliding_mean.jl"))
include(joinpath("Photometry","construct.jl"))


 export launch
 export carica
 export generate_offsets, add_offsets
 export collect_traces, load_traces
 export sliding_mean, normalise_sliding_mean
 export construct_photo

end
