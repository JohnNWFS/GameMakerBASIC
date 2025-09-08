function get_precedence(op) {
    switch (string_upper(op)) {
        // Logical operators (lowest precedence)
        case "OR":
            return 0;
        case "AND": 
            return 1;
        // Relational comparisons
        case "=": case "<>": case "<": case ">": case "<=": case ">=":
            return 2;
        // Add/subtract
        case "+": case "-":
            return 3;
        // Multiply/divide/mod
        case "*": case "/": case "\\": case "%": case "MOD":
            return 4;
        // Exponentiation (highest precedence)
        case "^":
            return 5;
        default:
            return 0;
    }
}