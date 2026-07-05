%ifndef BOOL_ASM
%define BOOL_ASM

; -----------------
; BOOLEAN CONSTANTS
; -----------------

TRUE    equ 1
FALSE   equ 0

; ---------------
; BOOLEAN HELPERS
; ---------------

section .data
    bool_true_str       db "true", 0
    bool_false_str      db "false", 0

section .text


    ;;; `bool_to_str(val rdi: int) -> str_ptr rax: *char`
    ;;;
    ;;; Converts a truthy/falsy integer to a pointer to "true" or "false" string.
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] val: integer to convert (nonzero = truthy, zero = falsy)
    ;;;
    ;;; Returns:
    ;;;   * [rax] str_ptr: pointer to the null-terminated string "true" or "false"
    bool_to_str:
        lea rax, [rel bool_false_str]
        cmp rdi, 0
        je .done
        lea rax, [rel bool_true_str]
        .done:
            ret


    ;;; `str_to_bool(string rdi: *char) -> result rax: int`
    ;;;
    ;;; Parses a null-terminated string as a boolean value.
    ;;;
    ;;; Case-sensitive: only the exact string "true" returns TRUE.
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;
    ;;; Returns:
    ;;;   * [rax] result: TRUE (1) if the string is "true", FALSE (0) otherwise
    str_to_bool:
        cmp byte [rdi], 't'
        jne .return_false
        cmp byte [rdi + 1], 'r'
        jne .return_false
        cmp byte [rdi + 2], 'u'
        jne .return_false
        cmp byte [rdi + 3], 'e'
        jne .return_false
        cmp byte [rdi + 4], 0
        jne .return_false
        mov rax, TRUE
        ret
        .return_false:
            mov rax, FALSE
            ret


%endif; BOOL_ASM
