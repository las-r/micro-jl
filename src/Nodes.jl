# microjl nodes
# by las-r

module Nodes
    # exceptions
    struct Break <: Exception end
    struct Return <: Exception
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
end