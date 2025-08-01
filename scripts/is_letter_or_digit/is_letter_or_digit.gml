function is_letter_or_digit(ch) {
    return is_letter(ch) || (ord(ch) >= 48 && ord(ch) <= 57);
}