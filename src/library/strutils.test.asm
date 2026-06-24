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

    test_is_empty_true db 'is_empty should return 1 for an empty string', 0xA, 0
    test_is_empty_true_len equ $ - test_is_empty_true - 1
    test_is_empty_false db 'is_empty should return 0 for a non-empty string', 0xA, 0
    test_is_empty_false_len equ $ - test_is_empty_false - 1
    test_is_empty_true_str db '', 0
    test_is_empty_false_str db 'not empty', 0

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

    test_is_digit db 'is_digit should return 1 for a digit character', 0xA, 0
    test_is_digit_len equ $ - test_is_digit - 1
    test_is_digit_char db '5', 0
    test_is_digit_char_len equ $ - test_is_digit_char

    test_is_not_digit db 'is_digit should return 0 for a non-digit character', 0xA, 0
    test_is_not_digit_len equ $ - test_is_not_digit - 1
    test_is_not_digit_char db 'A', 0
    test_is_not_digit_char_len equ $ - test_is_not_digit_char

    test_is_upper db 'is_uppercase should return 1 for an uppercase character', 0xA, 0
    test_is_upper_len equ $ - test_is_upper - 1
    test_is_upper_char db 'G', 0
    test_is_upper_char_len equ $ - test_is_upper_char

    test_is_not_upper db 'is_uppercase should return 0 for a non-uppercase character', 0xA, 0
    test_is_not_upper_len equ $ - test_is_not_upper - 1
    test_is_not_upper_char db 'g', 0
    test_is_not_upper_char_len equ $ - test_is_not_upper_char

    test_is_lower db 'is_lowercase should return 1 for a lowercase character', 0xA, 0
    test_is_lower_len equ $ - test_is_lower - 1
    test_is_lower_char db 'm', 0
    test_is_lower_char_len equ $ - test_is_lower_char

    test_is_not_lower db 'is_lowercase should return 0 for a non-lowercase character', 0xA, 0
    test_is_not_lower_len equ $ - test_is_not_lower - 1
    test_is_not_lower_char db 'M', 0
    test_is_not_lower_char_len equ $ - test_is_not_lower_char

    test_is_alphanumeric db 'is_alphanumeric should return 1 for an alphanumeric character', 0xA, 0
    test_is_alphanumeric_len equ $ - test_is_alphanumeric - 1
    test_is_alphanumeric_char db 'Z', 0
    test_is_alphanumeric_char_len equ $ - test_is_alphanumeric_char

    test_is_not_alphanumeric db 'is_alphanumeric should return 0 for a non-alphanumeric character', 0xA, 0
    test_is_not_alphanumeric_len equ $ - test_is_not_alphanumeric - 1
    test_is_not_alphanumeric_char db '!', 0
    test_is_not_alphanumeric_char_len equ $ - test_is_not_alphanumeric_char

    test_itoa db 'itoa should convert integer 12345 to string', 0xA, 0
    test_itoa_len equ $ - test_itoa - 1
    test_itoa_expected_str db '12345', 0
    test_itoa_expected_str_len equ $ - test_itoa_expected_str

    test_atoi db 'atoi should convert string "67890" to integer 67890', 0xA, 0
    test_atoi_len equ $ - test_atoi - 1
    test_atoi_input_str db '67890', 0
    test_atoi_input_str_len equ $ - test_atoi_input_str

    test_base_to_str db 'base_to_str should convert integer 237 to string "ED" in base 16', 0xA, 0
    test_base_to_str_len equ $ - test_base_to_str - 1
    test_base_to_str_input_int equ 237
    test_base_to_str_input_base equ 16
    test_base_to_str_expected_str db 'ED', 0
    test_base_to_str_expected_str_len equ $ - test_base_to_str_expected_str

    test_base_to_str_base2_str db 'base_to_str should convert integer 37 to string "100101" in base 2', 0xA, 0
    test_base_to_str_base2_str_len equ $ - test_base_to_str_base2_str
    test_base_to_str_input_int_2 equ 37
    test_base_to_str_input_base_2 equ 2
    test_base_to_str_expected_str_2 db '100101', 0
    test_base_to_str_expected_str_2_len equ $ - test_base_to_str_expected_str_2

; UNINITIALIZED DATA
; ------------------

section .bss
    number_buffer resb 100                ; Reserve 100 bytes for the integer to string conversion buffer

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

    ; ------- TEST: is_empty -------

    ; Test case 1: Empty string
    mov rdi, test_is_empty_true_str
    call is_empty
    ; rax now contains the result of the check
    cmp rax, 1                      ; Compare the result with the expected value (1 for empty string)
    TEST is_empty_true

    ; Test case 2: Non-empty string
    mov rdi, test_is_empty_false_str
    call is_empty
    ; rax now contains the result of the check
    cmp rax, 0                      ; Compare the result with the expected value (0 for non-empty string)
    TEST is_empty_false

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

    ; ------ TEST: is_digit -------

    mov rdi, test_is_digit_char
    call is_digit
    ; rax now contains the result of the check
    cmp rax, 1                      ; Compare the result with the expected value (1 for digit character)
    TEST is_digit

    mov rdi, test_is_not_digit_char
    call is_digit
    ; rax now contains the result of the check
    cmp rax, 0                      ; Compare the result with the expected value (0 for non-digit character)
    TEST is_not_digit

    ; ------ TEST: is_uppercase -------

    mov rdi, test_is_upper_char
    call is_uppercase
    ; rax now contains the result of the check
    cmp rax, 1                      ; Compare the result with the expected value (1 for uppercase character)
    TEST is_upper

    mov rdi, test_is_not_upper_char
    call is_uppercase
    ; rax now contains the result of the check
    cmp rax, 0                      ; Compare the result with the expected value (0 for non-uppercase character)
    TEST is_not_upper

    ; ------ TEST: is_lowercase -------

    mov rdi, test_is_lower_char
    call is_lowercase
    ; rax now contains the result of the check
    cmp rax, 1                      ; Compare the result with the expected value (1 for lowercase character)
    TEST is_lower

    mov rdi, test_is_not_lower_char
    call is_lowercase
    ; rax now contains the result of the check
    cmp rax, 0                      ; Compare the result with the expected value (0 for non-lowercase character)
    TEST is_not_lower

    ; ------ TEST: is_alphanumeric -------

    mov rdi, test_is_alphanumeric_char
    call is_alphanumeric
    ; rax now contains the result of the check
    cmp rax, 1                      ; Compare the result with the expected value (1 for alphanumeric character)
    TEST is_alphanumeric

    mov rdi, test_is_not_alphanumeric_char
    call is_alphanumeric
    ; rax now contains the result of the check
    cmp rax, 0                      ; Compare the result with the expected value (0 for non-alphanumeric character)
    TEST is_not_alphanumeric

    ; ------- TEST: itoa -------

    mov rdi, 12345                  ; The integer to convert
    mov rsi, number_buffer          ; The buffer to store the resulting string
    call itoa                       ; Call the itoa function to convert the integer to a string
    ; rax now contains the pointer to the null-terminated string in number_buffer
    ; We can now compare the resulting string with the expected string "12345"
    mov rdi, number_buffer          ; Pointer to the resulting string
    mov rsi, test_itoa_expected_str ; Pointer to the expected string
    call strcmp                     ; Compare the two strings
    cmp rax, 0                      ; Check if the strings are equal
    TEST itoa

    ; ------- TEST: atoi -------

    mov rdi, test_atoi_input_str    ; Pointer to the input string "67890"
    call atoi                       ; Call the atoi function to convert the string to an integer
    ; rax now contains the integer value 67890
    cmp rax, 67890                  ; Compare the result with the expected integer value
    TEST atoi

    ; ------- TEST: base_to_str -------

    mov rdi, test_base_to_str_input_int  ; The integer to convert (237)
    mov rsi, number_buffer               ; The buffer to store the resulting string
    mov rdx, test_base_to_str_input_base ; The base to convert to (16)
    call base_to_str                     ; Call the base_to_str function to convert the integer to a string in the specified base

    ; rax now contains the pointer to the null-terminated string in number_buffer
    ; We can now compare the resulting string with the expected string "ED"
    mov rdi, number_buffer               ; Pointer to the resulting string
    mov rsi, test_base_to_str_expected_str ; Pointer to the expected string "ED"
    call strcmp                          ; Compare the two strings
    cmp rax, 0                           ; Check if the strings are equal
    TEST base_to_str

    mov rdi, test_base_to_str_input_int_2  ; The integer to convert (37)
    mov rsi, number_buffer                 ; The buffer to store the resulting string
    mov rdx, test_base_to_str_input_base_2 ; The base to convert to (2)
    call base_to_str                       ; Call the base_to_str function to convert the integer

    ; rax now contains the pointer to the null-terminated string in number_buffer
    ; We can now compare the resulting string with the expected string "100101"
    mov rdi, number_buffer                 ; Pointer to the resulting string
    mov rsi, test_base_to_str_expected_str_2 ; Pointer to the expected string "100101"
    call strcmp                            ; Compare the two strings
    cmp rax, 0                             ; Check if the strings are equal
    TEST base_to_str_base2_str

    ; TODO: TEST is a keyword too, rename this
    ;       Probably a full assertion framework is needed. (e.g. ASSERT_EQ, ASSERT_LE)

    ; ------- ALL TESTS PASSED -------

    EXIT EXIT_SUCCESS


; TEST FAILURES
; -------------

.strlen_failed:
    FAIL test_strlen

.is_empty_true_failed:
    FAIL test_is_empty_true

.is_empty_false_failed:
    FAIL test_is_empty_false

.strcmp_equal_failed:
    FAIL test_strcmp_equal

.strcmp_less_failed:
    FAIL test_strcmp_less

.strcmp_greater_failed:
    FAIL test_strcmp_greater

.is_digit_failed:
    FAIL test_is_digit

.is_not_digit_failed:
    FAIL test_is_not_digit

.is_upper_failed:
    FAIL test_is_upper

.is_not_upper_failed:
    FAIL test_is_not_upper

.is_lower_failed:
    FAIL test_is_lower

.is_not_lower_failed:
    FAIL test_is_not_lower

.itoa_failed:
    FAIL test_itoa

.atoi_failed:
    FAIL test_atoi

.base_to_str_failed:
    FAIL test_base_to_str

.base_to_str_base2_str_failed:
    FAIL test_base_to_str_base2_str
