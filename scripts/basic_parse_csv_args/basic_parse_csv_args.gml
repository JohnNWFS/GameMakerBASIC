/// Parse comma-separated command arguments (quote- and paren-aware).
function basic_parse_csv_args(str) {
    return split_on_unquoted_commas(str);
}