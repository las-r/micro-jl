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
        # array literals
        if peek(tokens) == "["
            eat!(tokens)
            items = Nodes.Node[]
            if peek(tokens) != "]"
                push!(items, parseexpr(tokens))
                while peek(tokens) == ","
                    eat!(tokens)
                    push!(items, parseexpr(tokens))
                end
            end
            if peek(tokens) == "]"
                eat!(tokens)
            else
                error("Expecting closing ']'")
            end
            node =  Nodes.Array(items)
            while peek(tokens) == ":"
                eat!(tokens)
                iexpr = parseatom(tokens)
                node = Nodes.Index(node, iexpr)
            end
            return node
        end

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
                error("Expected closing ')'")
            end
            node = expr
            while peek(tokens) == ":"
                eat!(tokens)
                iexpr = parseatom(tokens)
                node = Nodes.Index(node, iexpr)
            end
            return node
        end

        # literal
        tok = eat!(tokens)
        if startswith(tok, '"') && endswith(tok, '"')
            node = Nodes.Literal(chop(tok, head=1, tail=1))
        elseif (val = tryparse(Int, tok)) !== nothing
            node = Nodes.Literal(val)
        elseif (val = tryparse(Float64, tok)) !== nothing
            node = Nodes.Literal(val)
        else
            node = Nodes.Variable(tok)
        end

        # array indexing
        while peek(tokens) == ":"
            eat!(tokens)
            iexpr = parseatom(tokens)
            node = Nodes.Index(node, iexpr)
        end

        return node
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
            elseif left isa Nodes.Index
                return Nodes.IndexAssign(left.arr, left.idx, right)
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