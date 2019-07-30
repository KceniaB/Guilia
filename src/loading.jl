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
        return data isa AbstractDict ? data : table(columns(data))
    elseif file_type == "jld2"
        file = FileIO.load(filename)
        data = file[collect(keys(file))[1]]
        data = table(data)
    elseif file_type == "csv"        
        return table(CSVFiles.load(filename))
    else
        println("file type unknown")
        return nothing
    end
end
