# microjl Lexer
# by las-r

module Lexer
    # token pattern
    const REGEX = r"""
        (?<COMMENT>  //[^\n]*) |
        (?<NUMBER>   \d+(?:\.\d+)?) |
        (?<STRING>   "(?:\\.|[^"\\])*") |
        (?<KEYWORD>  \b(end|if|else|while|func|break|return|import)\b) |
        (?<OPER>     ==|<=|>=|&&|\|\||[+\-*/%<>~&\|^()!:=,\[\]]) |
        (?<IDENT>    [a-zA-Z_]\w*) |
        (?<SKIP>     [ \t\r\n]+) |
        (?<MISMATCH> .)
    """x

    # tokens object
    mutable struct Tokens
        tokens::Vector{String}
        i::Int
    end
    Tokens(tokens) = Tokens(tokens, 1)
    function can_eat(t::Tokens, inc=1)
        return t.i <= length(t.tokens) - inc
    end
    function eat!(t::Tokens, inc=1)
        val = t.tokens[t.i] 
        t.i += inc
        return val
    end
    function peek(t::Tokens, off=0)
        idx = t.i + off
        if idx > length(t.tokens)
            return ""
        end
        return t.tokens[idx]
    end
    function expect!(t::Tokens, val)
        tok = peek(t)
        if tok != val
            error("Expected $(val), got $(tok)")
        end
        eat!(t)
    end

    # tokenizer
    function tokenize(code)
        tokens = String[]
        for m in eachmatch(REGEX, code)
            typ = nothing
            for name in keys(m)
                if m[name] !== nothing
                    typ = name
                    break
                end
            end
            val = m.match
            if typ == "SKIP" || typ == "COMMENT"
                continue
            elseif typ == "MISMATCH"
                error("Unexpected token: $val")
            end
            push!(tokens, val)
        end
        return Tokens(tokens)
    end
end