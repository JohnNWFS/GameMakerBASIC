function is_right_associative(op) {
    return (op == "^" || string_upper(op) == "NOT");
}
