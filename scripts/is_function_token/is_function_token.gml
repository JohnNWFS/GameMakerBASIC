/// @function is_function_token(token)
/// @description Checks if a given token is a recognized BASIC function.
/// @param {string} token The token to check.
/// @returns {boolean} True if it's a function, false otherwise.
function is_function_token(token) {
    var upper_token = string_upper(token);
    // Add more functions here as you implement them in evaluate_postfix
    return upper_token == "RND" || upper_token == "ABS";
}