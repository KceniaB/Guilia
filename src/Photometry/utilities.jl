function  put_in_columns(args...)
    cols = (Widgets.div(className="column", arg) for arg in args)
    return Widgets.div(className = "columns", cols...)
end
