function regress_trace(v_sig,v_ref)
    x = hcat(v_ref,ones(length(v_ref)))
    o = fit!(LinReg(), (x,v_sig))
    reconstruction = v_sig .- (v_ref.*coef(o)[1])
    return reconstruction
end
