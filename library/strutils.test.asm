%include "library/strutils.asm"
%include "library/test-assert.asm"

section .data
    DEFINE_STR test_strlen_str, 'this is a test string', 0
    DEFINE_STR empty_str, '', 0

    DEFINE_STR test_str_1, 'Alice', 0
    DEFINE_STR test_str_2, 'Bob', 0

    DEFINE_STR test_itoa_str_1, '12345', 0
    DEFINE_STR test_itoa_str_2, '-6789', 0

    DEFINE_STR test_base_to_str_1, 'ED', 0
    DEFINE_STR test_base_to_str_2, '100101', 0

section .bss
    __test_number_buffer resb 96    ; Reserve 96 bytes for the test number buffer

section .text

global _start
_start:

    ; strlen
    ; ------

    TESTCASE "strlen should return the correct length of a string"

        mov rdi, test_strlen_str            
        call strlen                          
        ASSERT_EQ rax, test_strlen_str_len - 1, "correctly calculates the length of a string"

        mov rdi, empty_str
        call strlen                         
        ASSERT_EQ rax, 0, "correctly returns 0 for an empty string"

    ; is_empty
    ; --------

    TESTCASE "is_empty should correctly identify an empty string"

        mov rdi, empty_str
        call is_empty                         
        ASSERT_EQ rax, 1, "correctly returns 1 for an empty string"

        mov rdi, test_strlen_str
        call is_empty                         
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-empty string"

    ; strcmp
    ; ------

    TESTCASE "strcmp should correctly compare two strings"

        mov rdi, test_str_1
        mov rsi, test_str_1
        call strcmp
        ASSERT_EQ rax, 0, "correctly returns 0 for equal strings"

        mov rdi, test_str_1
        mov rsi, test_str_2
        call strcmp
        ASSERT_EQ rax, -1, "correctly returns -1 for str1 < str2"

        mov rdi, test_str_2
        mov rsi, test_str_1
        call strcmp
        ASSERT_EQ rax, 1, "correctly returns 1 for str1 > str2"

    ; is_digit
    ; --------

    TESTCASE "is_digit should correctly identify digit characters"

        mov rdi, '5'
        call is_digit
        ASSERT_EQ rax, 1, "correctly returns 1 for a digit character"

        mov rdi, 'a'
        call is_digit
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-digit character"

    ; is_uppercase
    ; ------------

    TESTCASE "is_uppercase should correctly identify uppercase characters"

        mov rdi, 'A'
        call is_uppercase
        ASSERT_EQ rax, 1, "correctly returns 1 for an uppercase character"

        mov rdi, 'a'
        call is_uppercase
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-uppercase character"

        mov rdi, '5'
        call is_uppercase
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-uppercase digit"

    ; is_lowercase
    ; ------------

    TESTCASE "is_lowercase should correctly identify lowercase characters"

        mov rdi, 'a'
        call is_lowercase
        ASSERT_EQ rax, 1, "correctly returns 1 for a lowercase character"

        mov rdi, 'A'
        call is_lowercase
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-lowercase character"

        mov rdi, '5'
        call is_lowercase
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-lowercase digit"

    ; is_alphanumeric
    ; ---------------

    TESTCASE "is_alphanumeric should correctly identify alphanumeric characters"

        mov rdi, 'a'
        call is_alphanumeric
        ASSERT_EQ rax, 1, "correctly returns 1 for a lowercase character"

        mov rdi, 'A'
        call is_alphanumeric
        ASSERT_EQ rax, 1, "correctly returns 1 for an uppercase character"

        mov rdi, '5'
        call is_alphanumeric
        ASSERT_EQ rax, 1, "correctly returns 1 for a digit character"

        mov rdi, '!'
        call is_alphanumeric
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-alphanumeric character"

    ; itoa
    ; ----
    
    TESTCASE "itoa should correctly convert integers to strings"

        mov rdi, 12345
        mov rsi, __test_number_buffer
        call itoa
        ASSERT_STR_EQ __test_number_buffer, test_itoa_str_1, "correctly converts a positive integer to string"

    ; atoi
    ; ----

    TESTCASE "atoi should correctly convert strings to integers"

        mov rdi, test_itoa_str_1
        call atoi
        ASSERT_EQ rax, 12345, "correctly converts a positive string to integer"

    ; base_to_str
    ; -----------

    TESTCASE "base_to_str should correctly convert integers to strings in different bases"

        mov rdi, 237
        mov rdx, 16
        mov rsi, __test_number_buffer
        call base_to_str
        ASSERT_STR_EQ __test_number_buffer, test_base_to_str_1, "correctly converts integer to hexadecimal string"

        mov rdi, 37
        mov rdx, 2
        mov rsi, __test_number_buffer
        call base_to_str
        ASSERT_STR_EQ __test_number_buffer, test_base_to_str_2, "correctly converts integer to binary string"

    ; str_to_base
    ; -----------

    TESTCASE "str_to_base should correctly convert strings in different bases to integers"

        lea rdi, [rel test_base_to_str_1]
        mov rsi, 16
        call str_to_base
        ASSERT_EQ rax, 237, "correctly converts hexadecimal string to integer"

        lea rdi, [rel test_base_to_str_2]
        mov rsi, 2
        call str_to_base
        ASSERT_EQ rax, 37, "correctly converts binary string to integer"


    ; All tests passed, exit with status 0
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
