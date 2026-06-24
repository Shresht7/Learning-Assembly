%include "src/library/strutils.asm"
%include "src/library/test-assert.asm"

section .data
    DEFINE_STR test_strlen_str, 'this is a test string', 0
    DEFINE_STR empty_str, '', 0

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

    TESTCASE "strlen should return 0 for an empty string"
        mov rdi, empty_str
        call strlen                         
        ASSERT_EQ rax, 0, "correctly returns 0 for an empty string"

    ; is_empty
    ; --------

    TESTCASE "is_empty should return 1 for an empty string"
        mov rdi, empty_str
        call is_empty                         
        ASSERT_EQ rax, 1, "correctly returns 1 for an empty string"

    TESTCASE "is_empty should return 0 for a non-empty string"
        mov rdi, test_strlen_str
        call is_empty                         
        ASSERT_EQ rax, 0, "correctly returns 0 for a non-empty string"



    ; All tests passed, exit with status 0
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
