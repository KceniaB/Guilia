"""
`carica`
since jld2 files are saved as dictionaries
it is painful to indicates always the variable name you want.
In this way it automatically calls the first key of the dictionary
and retunrs the variable stored
"""
function carica(filename)
    file_type = split(filename,".")[end]
    if  file_type == "jld"
        dictionary = BSON.load(filename)
        data = dictionary[collect(keys(dictionary))[1]]
        return data
    elseif file_type == "jld2"
        table(Flipping.carica(filename))
    end
end
