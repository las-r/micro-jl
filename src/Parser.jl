# microjl parser
# by las-r

module Parser
    using ..Lexer: Tokens, tokenize, peek, eat!, can_eat, expect!
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
            expect!(tokens, "]")
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
            expect!(tokens, ")")
            node = expr
            while peek(tokens) == ":"
                eat!(tokens)
                iexpr = parseatom(tokens)
                node = Nodes.Index(node, iexpr)
            end
            return node
        end

        # literal, function call, and variable
        tok = eat!(tokens)
        if startswith(tok, '"') && endswith(tok, '"')
            node = Nodes.Literal(chop(tok, head=1, tail=1))
        elseif (val = tryparse(Int, tok)) !== nothing
            node = Nodes.Literal(val)
        elseif (val = tryparse(Float64, tok)) !== nothing
            node = Nodes.Literal(val)
        elseif peek(tokens) == "("
            eat!(tokens)
            args = Nodes.Node[]
            if peek(tokens) != ")"
                push!(args, parseexpr(tokens))
                while peek(tokens) == ","
                    eat!(tokens)
                    push!(args, parseexpr(tokens))
                end
            end
            expect!(tokens, ")")
            node = Nodes.Call(tok, args)
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
        # if
        if peek(tokens) == "if"
            eat!(tokens)
            cond = parseexpr(tokens)
            body = Nodes.Node[]
            while can_eat(tokens) && peek(tokens) != "else" && peek(tokens) != "end"
                push!(body, parsestmt(tokens))
            end
            ebody = Nodes.Node[]
            if peek(tokens) == "else" 
                eat!(tokens)
                while can_eat(tokens) && peek(tokens) != "end"
                    push!(ebody, parsestmt(tokens))
                end
            end
            expect!(tokens, "end")
            return Nodes.If(cond, body, ebody)
        end

        # while
        if peek(tokens) == "while"
            eat!(tokens)
            cond = parseexpr(tokens)
            body = Nodes.Node[]
            while can_eat(tokens) && peek(tokens) != "end"
                push!(body, parsestmt(tokens))
            end
            expect!(tokens, "end")
            return Nodes.While(cond, body)
        end

        # break
        if peek(tokens) == "break"
            eat!(tokens)
            return Nodes.Break()
        end

        # function
        if peek(tokens) == "func"
            eat!(tokens)
            name = eat!(tokens)
            params = String[]
            if peek(tokens) == "("
                eat!(tokens)
                if peek(tokens) != ")"
                    push!(params, eat!(tokens))
                    while peek(tokens) == ","
                        eat!(tokens)
                        push!(params, eat!(tokens))
                    end
                end
                expect!(tokens, ")")
            end
            body = Nodes.Node[]
            while can_eat(tokens) && peek(tokens) != "end"
                push!(body, parsestmt(tokens))
            end
            expect!(tokens, "end")
            return Nodes.Define(name, params, body)
        end

        # return
        if peek(tokens) == "return"
            eat!(tokens)
            if can_eat(tokens) && !(peek(tokens) in ["end", "if", "else", "while", "break", "func", "return", "import"])
                value = parseexpr(tokens)
            else
                value = nothing
            end
            return Nodes.Return(value)
        end

        # assign
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