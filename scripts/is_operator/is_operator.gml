function is_operator(op) {
    return (op == "+" || op == "-" || op == "*" || op == "/" || op == "\\" || op == "^" || 
            op == "%" || string_upper(op) == "MOD" ||
            op == "=" || op == "<>" || op == "<" || op == ">" || op == "<=" || op == ">=" ||
            string_upper(op) == "AND" || string_upper(op) == "OR");
}