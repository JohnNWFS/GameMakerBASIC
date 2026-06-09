function get_precedence(op) {
    switch (string_upper(op)) {
        // Logical operators (lowest precedence)
        case "OR":
            return 0;
        case "AND":
            return 1;
        // Unary NOT (above AND, below relational)
        case "NOT":
            return 2;
        // Relational comparisons
        case "=": case "<>": case "<": case ">": case "<=": case ">=":
            return 3;
        // Add/subtract
        case "+": case "-":
            return 4;
        // Multiply/divide/mod
        case "*": case "/": case "\\": case "%": case "MOD":
            return 5;
        // Exponentiation (highest precedence)
        case "^":
            return 6;
        default:
            return 0;
    }
}