function basic_evaluate_expression_v2(expr) {
    var tokens = basic_tokenize_expression_v2(expr);
    if (dbg_on(DBG_FLOW)) show_debug_message("Tokens: " + string(tokens)); // for debug
    var postfix = infix_to_postfix(tokens);
    return evaluate_postfix(postfix);
}
