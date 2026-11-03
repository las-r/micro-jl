include("src/Micro.jl")
using .Micro

# microjl
# by las-r

# inbuilt functions
function ninput(x)
    print(x)
    return readline()
end

function ntype(x, t)
    if x isa Vector return "arr" end
    if x isa Float return "float" end
    if x isa Micro.Nodes.Func || !isempty(methods(x)) return "func" end
    if x isa Int return "int" end
    if x isa AbstractString return "string" end
end

function nconv(x, t)
    if t == "arr" return collect(x) end
    if t == "float" return x isa AbstractString ? parse(Float, x) : Float(x) end
    if t == "int" return x isa AbstractString ? parse(Int, x) : Int(x) end
    if t == "str" return string(x) end
    error("Unknown convertible type: $(t)")
end

function nadd(a, i, x)
    ac = deepcopy(a)
    insert!(ac, i + 1, x)
    return ac
end

function ndel(a, i)
    ac = deepcopy(a)
    deleteat!(ac, i + 1)
    return ac
end

function main()
    if length(ARGS) < 1
        println("usage: micro.exe <file.mic>")
        return 1
    end
    file = ARGS[1]
    code = read(file, String)

    tokens = Micro.Lexer.tokenize(code)
    ast = Micro.Parser.parseprog(tokens)

    env = Dict{String, Any}(
        "print" => println,
        "input" => ninput,
        "type" => ntype,
        "conv" => nconv,
        "len" => length,
        "add" => nadd,
        "del" => ndel
    )
    for n in ast
        Micro.Nodes.evaluate(n, env)
    end

    return 0
end

function julia_main()::Cint
    try
        return main()
    catch e
        showerror(stderr, e, catch_backtrace())
        return 1
    end
end