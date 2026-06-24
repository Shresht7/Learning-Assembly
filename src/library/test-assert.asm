%ifndef TEST_ASSERT_ASM
%define TEST_ASSERT_ASM

%include "src/library/stdio.asm"

section .data
    str_tc_prefix   db 10, "TESTCASE: ", 0
    str_fail        db "[ ", 27, "[31mFAIL", 27, "[0m ]: ", 0
    str_pass        db "[ ", 27, "[32mPASS", 27, "[0m ]: ", 0
    str_expected    db "   Expected: ", 0
    str_actual      db "   Actual: ", 0
    str_newline     db 10, 0

; TESTCASE
; --------

; TESTCASE <description>
;
; Defines a test case with a description in the data section and prints it to stdout.
%macro TESTCASE 1
    ; Define a test case with a description in the data section
    [section .data]
        %%desc: db %1, 10, 0
        %%desc_len: equ $ - %%desc
    
    __?SECT?__

    ; Push rax and rdi to preserve their values across the test case execution
    push rax
    push rdi

    ; Print TESTCASE: <description>
    mov rdi, str_tc_prefix              ; Load the address of the test case prefix into rdi
    call print_str                      ; Call the print_str function to print the test case prefix
    lea rdi, [rel %%desc]               ; Load the address of the test case description into rdi
    call print_str                      ; Call the print_str function to print the test case description

    ; Pop rdi and rax to restore their original values after the test case execution
    pop rdi
    pop rax
%endmacro

; ASSERTIONS
; ----------

%macro _ASSERT_BASE 4
    ; Define a description for the assertion in the data section
    [section .data]
        %%assert_desc: db %3, 0
    __?SECT?__

    ; Preserve Registers
    push rax
    push rdi
    push r14
    push r15

    ; Move expected (%1) and actual (%2) into registers for comparison
    mov r14, %1                         ; Move expected value into r14
    mov r15, %2                         ; Move actual value into r15

    cmp r14, r15                        ; Compare expected and actual values
    %4 %%passed                         ; Use the provided jump instruction as the success case

    %%failed:
        ; Print [FAIL]: <assertion_description>
        mov rdi, str_fail                  ; Load the address of the failure message into rdi
        call print_str                 ; Call the print_str function to print the failure message
        lea rdi, [rel %%assert_desc]         ; Load the address of the assertion description into rdi
        call print_str                 ; Call the print_str function to print the assertion description

        ; Print Expected: <expected_value>
        mov rdi, str_expected                  ; Load the address of the expected message into rdi
        call print_str                 ; Call the print_str function to print the expected message
        mov rdi, r14     ; Load the expected value into rdi
        call print_int                  ; Call the print_int function to print the expected value

        ; Print Actual: <actual_value>
        mov rdi, str_actual                  ; Load the address of the actual message into rdi
        call print_str                 ; Call the print_str function to print the actual message
        mov rdi, r15     ; Load the actual value into rdi
        call print_int                  ; Call the print_int function to print the actual value

        ; Final Newline
        mov rdi, str_newline                  ; Load the address of the newline string into rdi
        call print_str                 ; Call the print_str function to print a newline
        
        jmp %%done

    %%passed:
        ; Print [PASS]: <assertion_description>
        mov rdi, str_pass                  ; Load the address of the pass message into rdi
        call print_str
        lea rdi, [rel %%assert_desc]   ; Safely load relative address
        call print_str
        mov rdi, str_newline                  ; Load the address of the newline string into rdi
        call print_str

    %%done:
        ; Print a newline after the assertion result
        mov rdi, str_newline                  ; Load the address of the newline string into rdi
        call print_str                 ; Call the print_str function to print a newline

        ; Restore Registers (in reverse order)
        pop r15
        pop r14
        pop rdi
        pop rax
%endmacro

; ASSERT_EQ
; ---------

; ASSERT_EQ <actual>, <expected>, <description>
;
; Asserts that the expected value is equal to the actual value. If they are not equal
; it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_EQ 3
    _ASSERT_BASE %2, %1, %3, je         ; Passes if equal (je)
%endmacro

; ASSERT_NE
; ---------

; ASSERT_NE <actual>, <expected>, <description>
;
; Asserts that the expected value is not equal to the actual value. If they are equal
; it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_NE 3
    _ASSERT_BASE %2, %1, %3, jne        ; Passes if not equal (jne)
%endmacro

; ASSERT_LT
; ---------

; ASSERT_LT <actual>, <expected>, <description>
;
; Asserts that the expected value is less than the actual value. If it is not less than
; it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_LT 3
    _ASSERT_BASE %2, %1, %3, jl         ; Passes if less than (jl)
%endmacro

; ASSERT_LE
; ---------

; ASSERT_LE <actual>, <expected>, <description>
;
; Asserts that the expected value is less than or equal to the actual value.
; If it is not less than or equal to, it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_LE 3
    _ASSERT_BASE %2, %1, %3, jle        ; Passes if less than or equal to (jle)
%endmacro

; ASSERT_GT
; ---------

; ASSERT_GT <actual>, <expected>, <description>
;
; Asserts that the expected value is greater than the actual value. If it is not greater than
; it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_GT 3
    _ASSERT_BASE %2, %1, %3, jg         ; Passes if greater than (jg)
%endmacro

; ASSERT_GE
; ---------

; ASSERT_GE <actual>, <expected>, <description>
;
; Asserts that the expected value is greater than or equal to the actual value.
; If it is not greater than or equal to, it prints a failure message with the expected and actual values, along with a description.
%macro ASSERT_GE 3
    _ASSERT_BASE %2, %1, %3, jge        ; Passes if greater than or equal to (jge)
%endmacro

%endif; TEST_ASSERT_ASM
