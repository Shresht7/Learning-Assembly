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

    test_strcmp_equal db 'strcmp should return 0 for equal strings', 0xA, 0
    test_strcmp_equal_len equ $ - test_strcmp_equal - 1 
    test_strcmp_equal_1 db 'these are the same', 0
    test_strcmp_equal_1_len equ $ - test_strcmp_equal_1
    test_strcmp_equal_2 db 'these are the same', 0
    test_strcmp_equal_2_len equ $ - test_strcmp_equal_2

    test_strcmp_less db 'strcmp should return a negative value for str1 < str2', 0xA, 0
    test_strcmp_less_len equ $ - test_strcmp_less - 1
    test_strcmp_less_1 db 'Alice', 0
    test_strcmp_less_1_len equ $ - test_strcmp_less_1
    test_strcmp_less_2 db 'Bob', 0
    test_strcmp_less_2_len equ $ - test_strcmp_less_2

    test_strcmp_greater db 'strcmp should return a positive value for str1 > str2', 0xA, 0
    test_strcmp_greater_len equ $ - test_strcmp_greater - 1
    test_strcmp_greater_1 db 'Bob', 0
    test_strcmp_greater_1_len equ $ - test_strcmp_greater_1
    test_strcmp_greater_2 db 'Alice', 0
    test_strcmp_greater_2_len equ $ - test_strcmp_greater_2

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

    ; ------- TEST: strcmp -------

    ; Test case 1: Equal strings
    mov rdi, test_strcmp_equal_1
    mov rsi, test_strcmp_equal_2
    call strcmp
    ; rax now contains the result of the comparison
    cmp rax, 0
    TEST strcmp_equal

    ; Test case 2: str1 < str2
    mov rdi, test_strcmp_less_1
    mov rsi, test_strcmp_less_2
    call strcmp
    ; rax now contains the result of the comparison
    cmp rax, 0
    jg .strcmp_less_failed
    PASS test_strcmp_less

    ; Test case 3: str1 > str2
    mov rdi, test_strcmp_greater_1
    mov rsi, test_strcmp_greater_2
    call strcmp
    ; rax now contains the result of the comparison
    cmp rax, 0
    jl .strcmp_greater_failed
    PASS test_strcmp_greater

    ; ------- ALL TESTS PASSED -------

    EXIT EXIT_SUCCESS


; TEST FAILURES
; -------------

.strlen_failed:
    FAIL test_strlen

.strcmp_equal_failed:
    FAIL test_strcmp_equal

.strcmp_less_failed:
    FAIL test_strcmp_less

.strcmp_greater_failed:
    FAIL test_strcmp_greater
