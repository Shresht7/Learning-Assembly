%include "src/library/strutils.asm"

; Syscalls
SYSCALL_READ    equ 0
SYSCALL_WRITE   equ 1
SYSCALL_EXIT    equ 60

; File Descriptors
STDIN           equ 0
STDOUT          equ 1
STDERR          equ 2

; Exit Status Codes
EXIT_SUCCESS    equ 0
EXIT_FAILURE    equ 1

%macro PRINT 1
    mov rax, SYSCALL_WRITE          ; syscall: write
    mov rdi, STDOUT                 ; file descriptor: stdout
    mov rsi, %1                     ; buffer: pointer to the message
    mov rdx, %1_len                 ; count: length of the message
    syscall                         ; execute syscall
%endmacro

%macro FAIL 1         
    PRINT msg_fail                  ; Print "FAIL: "
    PRINT %1                        ; Print the test name
    ; PRINT %2                        ; Print the expected value
    ; PRINT %3                        ; Print the actual value
    EXIT EXIT_FAILURE               ; Exit with failure status
%endmacro

%macro EXIT 1
    mov rax, SYSCALL_EXIT           ; syscall: exit
    mov rdi, %1                     ; status: exit code
    syscall                         ; execute
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
