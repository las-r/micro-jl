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
    ast = Micro.Parser.parseprog(tokens)

    env = Dict()
    for n in ast
        Micro.Nodes.evaluate(n, env)
    end

    println(env)
    return 0
end

exit(main())