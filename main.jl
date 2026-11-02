include("src/Micro.jl")
using .Micro

# microjl
# by las-r

function main()
    if length(ARGS) < 1
        println("usage: micro.exe <file.mic>")
        return 1
    end
    file = ARGS[1]
    code = read(file, String)

    tokens = Micro.Lexer.tokenize(code)
end