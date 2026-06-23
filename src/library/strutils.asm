%ifndef STRUTILS_ASM
%define STRUTILS_ASM

; ----------------
; STRING UTILITIES
; ----------------

section .text

    ; strlen(rdi: *str) -> rax: length
    ; Returns the length of a null-terminated string.
    ;
    ; @param rdi: pointer to the null-terminated string
    ; @return rax: length of the string (not including the null terminator)
    strlen:
        mov rax, 0                      ; Initialize length counter to 0
    .strlen_loop:
        cmp byte [rdi + rax], 0         ; Compare the current byte (at memory address rdi (start) + rax (counter)) with the null terminator
        je .strlen_done                 ; Jump if equal (found null terminator) to the `.strlen_done` label
        inc rax                         ; Otherwise, increment the length counter
        jmp .strlen_loop                ; Jump back to the start of the loop for the next byte/character
    .strlen_done:
        ret                             ; Return from the function, with rax containing the length of the string

    ; is_empty(rdi: *str) -> rax: result
    ; Checks if a null-terminated string is empty.
    ;
    ; @param rdi: pointer to the null-terminated string
    ; @return rax: 1 if the string is empty, 0 otherwise
    is_empty:
        cmp byte [rdi], 0               ; Compare the first byte of the string with the null terminator
        je .is_empty_true                ; If equal, the string is empty, jump to `.is_empty_true`
        mov rax, 0                      ; Otherwise, set rax to 0 (false)
        ret
    .is_empty_true:
        mov rax, 1                      ; Set rax to 1 (true)
        ret

    ; strcmp(rdi: *str1, rsi: *str2) -> rax: result
    ; Compares two null-terminated strings.
    ;
    ; @param rdi: pointer to the first null-terminated string
    ; @param rsi: pointer to the second null-terminated string
    ; @return rax: 0 if the strings are equal, a negative value if str1 < str2, and a positive value if str1 > str2
    strcmp:
        xor rax, rax                    ; Clear rax to use it as a result accumulator
    .strcmp_loop:
        mov al, byte [rdi]              ; Load the current byte of str1 into al
        mov bl, byte [rsi]              ; Load the current byte of str2 into bl
        cmp al, bl                      ; Compare the two bytes
        jl .strcmp_less                 ; If str1 < str2, jump to the `.strcmp_less` label
        jg .strcmp_greater              ; If str1 > str2, jump to the `.strcmp_greater` label
        test al, al                     ; Check if we reached the null terminator of str1 (and str2, since they are equal so far)
        je .strcmp_equal                 ; If we reached the null terminator, the strings are equal, jump to the `.strcmp_equal` label
        inc rdi                         ; Move to the next byte in str1
        inc rsi                         ; Move to the next byte in str2
        jmp .strcmp_loop                ; Jump back to the start of the loop for the next comparison
    .strcmp_less:
        mov rax, -1                     ; Set rax to -1 to indicate str1 < str2
        ret                             
    .strcmp_greater:
        mov rax, 1                      ; Set rax to 1 to indicate str1 > str2
        ret                             
    .strcmp_equal:
        xor rax, rax                    ; Set rax to 0 to indicate str1 == str2
        ret                             

%endif; STRUTILS_ASM
