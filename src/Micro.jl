module Micro
    include("Nodes.jl")
    include("Lexer.jl")
    include("Parser.jl")

    # compat functions
    function pyrepr(x)
        if x isa AbstractString
            q = occursin('\'', x) && !occursin('"', x) ? '"' : '\''
            s = replace(x, "\\" => "\\\\", "\n" => "\\n", "\t" => "\\t", "\r" => "\\r")
            q == '\'' && (s = replace(s, "'" => "\\'"))
            return string(q, s, q)
        elseif x isa Vector
            return "[" * join(pyrepr.(x), ", ") * "]"
        elseif x === nothing
            return "None"
        else
            return string(x)
        end
    end
    pystr(x) = x isa AbstractString ? x : pyrepr(x)

    # inbuilt functions
    function nprint(args...)
        println(join(pystr.(args), " "))
    end

    function ninput(x)
        print(x)
        return readline()
    end

    function ntype(x)
        if x isa Vector return "arr" end
        if x isa Float64 return "float" end
        if x isa Nodes.Func || !isempty(methods(x)) return "func" end
        if x isa Integer return "int" end
        if x isa AbstractString return "string" end
    end

    function nconv(x, t)
        if t == "arr" return collect(x) end
        if t == "float" return x isa AbstractString ? parse(Float64, x) : Float64(x) end
        if t == "int" return x isa AbstractString ? parse(BigInt, x) : BigInt(x) end
        if t == "str" return string(x) end
        error("Unknown convertible type: $(t)")
    end

    function nadd(a, i, x)
        ac = deepcopy(a); insert!(ac, i + 1, x); return ac
    end

    function ndel(a, i)
        ac = deepcopy(a); deleteat!(ac, i + 1); return ac
    end

    # main
    function julia_main()::Cint
        try
            if length(ARGS) < 1
                println("usage: micro.exe <file.mic>")
                return 1
            end
            code = read(ARGS[1], String)

            tokens = Lexer.tokenize(code)
            ast = Parser.parseprog(tokens)

            env = Dict{String, Any}(
                "print" => nprint, "input" => ninput, "type" => ntype,
                "conv" => nconv, "len" => length, "add" => nadd, "del" => ndel
            )
            for n in ast
                Nodes.evaluate(n, env)
            end
            return 0
        catch e
            println(stderr, "error: ", e isa ErrorException ? e.msg : e)
            return 1
        end
    end
end