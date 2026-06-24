%include "src/library/strutils.asm"
%include "src/library/test-assert.asm"

section .data
    test_strlen_str db 'this is a test string', 0
    test_strlen_str_len equ $ - test_strlen_str - 1 ; Subtract 1 to exclude the null terminator from the length

section .text

global _start
_start:

    TESTCASE "strlen should return the correct length of a string"
        mov rdi, test_strlen_str            ; Move the pointer to the test string into rdi
        call strlen                         ; Call the strlen function to get the length of the string (in rax) 
        ASSERT_EQ rax, test_strlen_str_len, "correctly calculates the length of a string"

    ; All tests passed, exit with status 0
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
