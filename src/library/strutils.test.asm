%include "src/library/strutils.asm"
%include "src/library/test-assert.asm"

section .data
    DEFINE_STR test_strlen_str, 'this is a test string', 0
    DEFINE_STR empty_str, '', 0

    DEFINE_STR test_str_1, 'Alice', 0
    DEFINE_STR test_str_2, 'Bob', 0
section .text

global _start
_start:

    mov r8, 0                      ; Initialize test counter to 0
    mov r9, 0                      ; Initialize total tests counter to 0

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


    ; All tests passed, exit with status 0
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
