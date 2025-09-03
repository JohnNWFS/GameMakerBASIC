function get_precedence(op) {
switch (op) {
    case "=": case "<>": case "<": case ">": case "<=": case ">=": return 0;
    case "+": case "-": return 1;
    case "*": case "/": case "\\" : case "%": case "MOD": return 2;
    case "^": return 3;
    default: return 0;
}

}
