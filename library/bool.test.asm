%include "library/bool.asm"
%include "library/test-assert.asm"

section .data
    DEFINE_STR test_true_str, 'true', 0
    DEFINE_STR test_false_str, 'false', 0
    DEFINE_STR test_not_true_str, 'not_true', 0
    DEFINE_STR test_empty_str, '', 0
    DEFINE_STR test_upper_true_str, 'TRUE', 0

section .text

global _start
_start:

    ; bool_to_str
    ; -----------

    TESTCASE "bool_to_str should convert truthy values to 'true'"

        mov rdi, 1
        call bool_to_str
        ASSERT_STR_EQ rax, test_true_str, "correctly returns 'true' for 1"

        mov rdi, 42
        call bool_to_str
        ASSERT_STR_EQ rax, test_true_str, "correctly returns 'true' for 42 (nonzero)"

        mov rdi, -1
        call bool_to_str
        ASSERT_STR_EQ rax, test_true_str, "correctly returns 'true' for -1 (nonzero)"

    TESTCASE "bool_to_str should convert falsy values to 'false'"

        mov rdi, 0
        call bool_to_str
        ASSERT_STR_EQ rax, test_false_str, "correctly returns 'false' for 0"

    ; str_to_bool
    ; -----------

    TESTCASE "str_to_bool should return TRUE for 'true'"

        mov rdi, test_true_str
        call str_to_bool
        ASSERT_EQ rax, TRUE, "correctly returns TRUE for 'true'"

    TESTCASE "str_to_bool should return FALSE for non-'true' strings"

        mov rdi, test_false_str
        call str_to_bool
        ASSERT_EQ rax, FALSE, "correctly returns FALSE for 'false'"

        mov rdi, test_not_true_str
        call str_to_bool
        ASSERT_EQ rax, FALSE, "correctly returns FALSE for 'not_true'"

        mov rdi, test_empty_str
        call str_to_bool
        ASSERT_EQ rax, FALSE, "correctly returns FALSE for empty string"

    TESTCASE "str_to_bool is case-sensitive"

        mov rdi, test_upper_true_str
        call str_to_bool
        ASSERT_EQ rax, FALSE, "correctly returns FALSE for 'TRUE'"

    ; All tests passed, exit with status 0
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
