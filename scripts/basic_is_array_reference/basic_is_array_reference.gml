/// Helper function to check if a variable name is an array reference
function basic_is_array_reference(varName) {
    var open_paren = string_pos("(", varName);
    var close_paren = string_pos(")", varName);
    return (open_paren > 0 && close_paren > open_paren);
}

