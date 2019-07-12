"""
`carica`
since jld2 files are saved as dictionaries
it is painful to indicates always the variable name you want.
In this way it automatically calls the first key of the dictionary
and retunrs the variable stored
"""
function carica(filename)
    if split(filename,".")[end] == "jld"
        dictionary = BSON.load(filename)
        data = dictionary[collect(keys(dictionary))[1]]
        return data
    end
end
