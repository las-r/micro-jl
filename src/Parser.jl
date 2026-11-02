# microjl parser
# by las-r

module Parser
    using ..Lexer: Tokens, tokenize, peek, eat!, can_eat
    using ..Nodes

    # operator lists
    const UNOPS = ["-", "~", "!"]
    const BINOPS = ["+", "-", "*", "/", "%", "&", "|", "^", "==", "<=", ">=", "<", ">", "&&", "||"]

    # atom parser
    function parseatom(tokens::Tokens)
        # unary ops
        if peek(tokens) in UNOPS
            op = eat!(tokens)
            a = parseatom(tokens)
            return Nodes.UnaryOp(op, a)
        end

        # parentheses
        if peek(tokens) == "("
            eat!(tokens)
            expr = parseexpr(tokens)
            if eat!(tokens) != ")"
                error("Expected ')'")
            end
            return expr
        end

        # literal
        tok = eat!(tokens)
        if startswith(tok, '"') && endswith(tok, '"')
            return Nodes.Literal(chop(tok, head=1, tail=1))
        end
        val = tryparse(Int, tok)
        if val !== nothing
            return Nodes.Literal(val)
        end
        val = tryparse(Float64, tok)
        if val !== nothing
            return Nodes.Literal(val)
        end

        # variable
        return Nodes.Variable(tok)
    end

    # expression parser
    function parseexpr(tokens)
        x = parseatom(tokens)
        while can_eat(tokens) && peek(tokens) in BINOPS
            op = eat!(tokens)
            y = parseatom(tokens)
            x = Nodes.BinaryOp(x, op, y)
        end
        return x
    end

    # statement parser
    function parsestmt(tokens)
        # assignment
        left = parseexpr(tokens)
        if peek(tokens) == "="
            eat!(tokens)
            right = parseexpr(tokens)
            if left isa Nodes.Variable
                return Nodes.Assign(left.name, right)
            end
            error("Invalid assignment target")
        end

        # fallback
        return left
    end

    # program parser
    function parseprog(tokens)
        nodes = Nodes.Node[]
        while can_eat(tokens)
            push!(nodes, parsestmt(tokens))
        end
        return nodes
    end
end