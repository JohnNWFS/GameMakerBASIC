/// @function split_on_unquoted_colons(line)
/// @description Split a line on top-level colons, ignoring colons inside quoted strings
///              or after an apostrophe REM comment.
function split_on_unquoted_colons(line) {
    return basic_split_delimited(line, ":", false, false, true, false, false);
}