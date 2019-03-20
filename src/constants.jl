const analysis_options = OrderedDict(
    "" => nothing,
    "Cumulative" => GroupSummaries.cumulative,
    "Density" => GroupSummaries.density,
    "Frequency" => GroupSummaries.frequency,
    "Hazard" => GroupSummaries.hazard,
    "Local Regression" => GroupSummaries.localregression,
    "Expected Value" => GroupSummaries.expectedvalue
    )
