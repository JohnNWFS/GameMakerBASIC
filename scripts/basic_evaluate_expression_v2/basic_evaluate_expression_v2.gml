function basic_evaluate_expression_v2(expr) {
    var tokens = basic_tokenize_expression_v2(expr);
    dbg_log(DBG_FLOW, "Tokens: " + string(tokens)); // for debug
    var postfix = infix_to_postfix(tokens);
    return evaluate_postfix(postfix);
}
