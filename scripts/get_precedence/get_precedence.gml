function get_precedence(op) {
    switch (op) {
        case "+": return 1;
        case "-": return 1;
        case "*": return 2;
        case "/": return 2;
        case "^": return 3;
        default: return 0;
    }
}
