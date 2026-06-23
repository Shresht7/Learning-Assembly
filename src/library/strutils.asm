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

    ; print_str(rdi: *str)
    ; Prints a null-terminated string to stdout.
    ;
    ; @param rdi: pointer to the null-terminated string
    ; @return: nothing
    print_str:
        push rdi                        ; Save the pointer to the string on the stack for safekeeping while we calculate its length

        call strlen                     ; Call the strlen function to get the length of the string (in rax)
        mov rdx, rax                    ; Move the length of the string into rdx (the count for the write syscall)

        pop rsi                         ; Restore the pointer to the string from the stack into rsi (the buffer for the write syscall)

        mov rax, SYSCALL_WRITE          ; Set rax to the syscall number for write
        mov rdi, STDOUT                 ; Set rdi to the file descriptor for stdout
        syscall                         ; Execute the write syscall to print the string to stdout

        ret



%endif; STRUTILS_ASM
