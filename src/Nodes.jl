# microjl nodes
# by las-r

module Nodes
    # exceptions
    struct BreakE <: Exception end
    struct ReturnE <: Exception
        value
    end

    # node parent
    abstract type Node end

    # literal node
    struct Literal <: Node
        value
    end
    function evaluate(n::Literal, env)
        return n.value
    end

    # variable nodes
    struct Variable <: Node
        name::String
    end
    function evaluate(n::Variable, env)
        return env[n.name]
    end

    struct Assign <: Node
        name::String
        val::Node
    end
    function evaluate(n::Assign, env)
        env[n.name] = evaluate(n.val, env)
    end

    # operator nodes
    struct UnaryOp <: Node
        op::String
        x::Node
    end
    function evaluate(n::UnaryOp, env)
        x = evaluate(n.x, env)
        if n.op == "-" return -x end
        if n.op == "~" return ~x end
        if n.op == "!" return Int(!x) end
        error("Unknown unary operator: $(n.op)") 
    end

    struct BinaryOp <: Node
        x::Node
        op::String
        y::Node
    end
    function evaluate(n::BinaryOp, env)
        x = evaluate(n.x, env)
        if n.op == "&&" return Int(x && evaluate(n.y, env)) end
        if n.op == "||" return Int(x || evaluate(n.y, env)) end
        y = evaluate(n.y, env)
        if n.op == "+" return x + y end
        if n.op == "-" return x - y end
        if n.op == "*" return x * y end
        if n.op == "/" return x / y end
        if n.op == "%" return x % y end
        if n.op == "&" return x & y end
        if n.op == "|" return x | y end
        if n.op == "^" return xor(x, y) end
        if n.op == "==" return int(x == y) end
        if n.op == "<=" return int(x <= y) end
        if n.op == ">=" return int(x >= y) end
        if n.op == "<" return int(x < y) end
        if n.op == ">" return int(x > y) end
        error("Unknown binary operator: $(n.op)") 
    end

    # array nodes
    struct Array <: Node
        items::Vector{Node}
    end
    function evaluate(n::Array, env)
        return Any[evaluate(i, env) for i in n.items]
    end

    struct Index <: Node
        arr::Node
        idx::Node
    end
    function evaluate(n::Index, env)
        arr = evaluate(n.arr, env)
        idx = evaluate(n.idx, env)
        return arr[idx + 1]
    end

    struct IndexAssign <: Node
        arr::Node
        idx::Node
        val::Node
    end
    function evaluate(n::IndexAssign, env)
        arr = evaluate(n.arr, env)
        idx = evaluate(n.idx, env)
        val = evaluate(n.val, env)
        arr[idx + 1] = val
    end

    # control flow nodes
    struct If <: Node
        cond::Node
        body::Vector{Node}
        ebody::Vector{Node}
    end
    function evaluate(n::If, env) 
        if evaluate(n.cond, env) != 0
            for o in n.body
                eval(o, env)
            end
        else
            for o in n.ebody
                eval(o, env)
            end
        end
    end

    struct While <: Node
        cond::Node
        body::Vector{Nodes}
    end
    function evaluate(n::While, env)
        try
            while evaluate(n.cond, env) != 0
                for o in self.body
                    evaluate(o, env)
                end
            end
        catch e
            if !(e isa BreakE)
                rethrow(e)
            end
        end
    end

    struct Break <: Node end
    function evaluate(n::Break, env)
        throw(BreakE)
    end
end