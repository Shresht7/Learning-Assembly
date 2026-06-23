; Library
%include "src/library/strutils.asm"
%include "src/library/syscalls.asm"

; MACROS
; ------

%macro FAIL 1         
    PRINT msg_fail                  ; Print "FAIL: "
    PRINT %1                        ; Print the test name
    ; PRINT %2                        ; Print the expected value
    ; PRINT %3                        ; Print the actual value
    EXIT EXIT_FAILURE               ; Exit with failure status
%endmacro

; INITIALIZED DATA
; ----------------

section .data
    newline db 0xA
    newline_len equ 1

    msg_fail db 0x1b, '[33mFAIL: ', 0x1b, '[0m' 
    msg_fail_len equ $ - msg_fail
    
    test_strlen db 'strlen should return the length of this string', 0xA, 0
    test_strlen_len equ $ - test_strlen

; MAIN
; ----

section .text
global _start

_start:

    ; ----------
    ; TEST CASES
    ; ----------

    ; ------- TEST: strlen -------

    mov rdi, test_strlen
    call strlen
    ; rax now contains the length of the string
    cmp rax, test_strlen_len  ; Compare the result with the expected length
    jne .strlen_failed  ; If not equal, jump to the failure label
    ; If equal, continue with the next test or exit

    ; ------- ALL TESTS PASSED -------

    EXIT EXIT_SUCCESS


; TEST FAILURES
; -------------

.strlen_failed:
    FAIL test_strlen
