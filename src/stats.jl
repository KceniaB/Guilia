using MixedModels
using Distributions
# using HypothesisTests
# using Distances
# ##
stim = launch()
t = stim[][:data][]
df = DataFrame(t)
#union(df[df.Area .== "NA",:Session])
categorical!(df,:Protocol)
levels!(df[:Protocol],["80/40","60/30","40/20"])
categorical!(df,:Gen)
categorical!(df,:Stim)
levels(df[:Stim])
categorical!(df,:Wall)
levels(df[:Wall])
levels!(df[:Wall],["false","true"])
##
function Likelyhood_Ratio_test(simple,full)
    degrees = dof(full) - dof(simple)
    ccdf(Distributions.Chisq(degrees), deviance(simple) - deviance(full))
end

function AIC_test(candidate, simpler)
    exp((aic(candidate) - aic(simpler))/2)
end
function AICc(model)
    aic(model) + ((2*(dof(model)^2) + 2*dof(model))/(nobs(model) - dof(model) - 1))
end
function AICc_test(candidate, simpler)
    exp((AICc(candidate) - AICc(simpler))/2)
end
##
zero_effects = fit(LinearMixedModel, @formula( AfterLast ~ 1 + (1|MouseID)), df)
protocol_effect = fit(LinearMixedModel, @formula( AfterLast ~ 1 + Protocol + (1|MouseID)), df)
barrier_effect = fit(LinearMixedModel, @formula( AfterLast ~ 1 + Wall  + (1|MouseID)), df)
AIC_test(protocol_effect,zero_effects)
AICc_test(protocol_effect,zero_effects)
Likelyhood_Ratio_test(zero_effects,protocol_effect)

Without_interaction = fit(LinearMixedModel, @formula( AfterLast ~ 1 + Protocol + Wall + (1|MouseID)), df);
BarrProt_interaction = fit(LinearMixedModel, @formula( AfterLast ~ 1 + Protocol + Wall + Protocol*Wall + (1|MouseID)), df);

AIC_test(BarrProt_interaction,Without_interaction)
AICc_test(BarrProt_interaction,Without_interaction)
Likelyhood_Ratio_test(Without_interaction,BarrProt_interaction)
