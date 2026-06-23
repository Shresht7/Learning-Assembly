; Library
%include "src/library/strutils.asm"
%include "src/library/syscalls.asm"

; MACROS
; ------

%macro PASS 1
    PRINT msg_pass                  ; Print "PASS: "
    PRINT %1                        ; Print the test name
%endmacro

%macro FAIL 1         
    PRINT msg_fail                  ; Print "FAIL: "
    PRINT %1                        ; Print the test name
    ; PRINT %2                        ; Print the expected value
    ; PRINT %3                        ; Print the actual value
    EXIT EXIT_FAILURE               ; Exit with failure status
%endmacro

%macro TEST 1
    jne .%1_failed                  ; If the test fails, jump to the failure label
    inc r8                          ; Increment the test counter
    inc r9                          ; Increment the total tests counter
    PASS test_%1                    ; Print "PASS: " followed by the test name
%endmacro

; INITIALIZED DATA
; ----------------

section .data
    newline db 0xA
    newline_len equ 1

    msg_pass db 0x1b, '[32mPASS: ', 0x1b, '[0m'
    msg_pass_len equ $ - msg_pass

    msg_fail db 0x1b, '[33mFAIL: ', 0x1b, '[0m' 
    msg_fail_len equ $ - msg_fail
    
    test_strlen db 'strlen should return the length of this string', 0xA, 0
    test_strlen_len equ $ - test_strlen - 1 ; Exclude the null terminator from the length

; MAIN
; ----

section .text
global _start

_start:

    ; ----------
    ; TEST CASES
    ; ----------

    mov r8, 0                      ; Initialize test counter to 0
    mov r9, 0                      ; Initialize total tests counter to 0

    ; ------- TEST: strlen -------

    mov rdi, test_strlen
    call strlen
    ; rax now contains the length of the string
    mov r10, rax                    ; Store the result in r10 for comparison
    cmp r10, test_strlen_len        ; Compare the result with the expected length
    TEST strlen

    ; ------- ALL TESTS PASSED -------

    EXIT EXIT_SUCCESS


; TEST FAILURES
; -------------

.strlen_failed:
    FAIL test_strlen
