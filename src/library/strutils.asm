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

    ; read_str(rdi: *buffer, rsi: buffer_size) -> rax: bytes_read
    ; Reads a string from stdin into a buffer.
    ;
    ; @param rdi: pointer to the buffer where the string will be stored
    ; @param rsi: size of the buffer (maximum number of bytes to read)
    ; @return rax: number of bytes read (excluding the null terminator)
    read_str:
        ; Shuffle the parameters to match the syscall convention for read
        mov rdx, rsi                    ; Move the buffer size into rdx (the count for the read syscall)
        mov rsi, rdi                    ; Move the pointer to the buffer into rsi (the buffer for the read syscall)
        mov rdi, STDIN                  ; Set rdi to the file descriptor for stdin
        mov rax, SYSCALL_READ           ; Set rax to the syscall number for read
        syscall                         ; Execute the read syscall to read input from stdin into the buffer
        ; Linux will pause the program until the user presses Enter, and then it will return the number of bytes read in rax.

        ; Check the result of the read syscall
        cmp rax, 0                       ; Check if the number of bytes read is zero (indicating EOF)
        je .read_str_eof                ; If EOF, jump to the `.read_str_eof` label to handle it
        jl .read_str_error                ; If rax is negative, an error occurred, so jump to the `.read_str_error` label 

        ; If we reach here, the read was successful and rax contains the number of bytes read
        dec rax                          ; Decrement rax to get the index of the last character (excluding the null terminator)
        cmp byte [rsi + rax], 0xA          ; Check if the last character read is a newline (0xA)
        jne .read_str_not_newline          ; If it's not a newline, jump to the `.read_str_not_newline` label

        ; If the last character is a newline, replace it with a null terminator
        mov byte [rsi + rax], 0          ; Replace the newline character with a null terminator
        jmp .read_str_done                ; Jump to the `.read_str_done` label to finish the function
        ; we leave rax decremented as it is the true length of the string (excluding the null terminator)

    .read_str_not_newline:
        inc rax                          ; If the last character is not a newline, increment rax to account for the null terminator

    .read_str_eof:
        ; If we reach here, it means we hit EOF (rax is 0) or we have a valid string without a newline. We need to ensure the string is null-terminated.
        mov byte [rsi + rax], 0          ; Null-terminate the string at the current index (rax)

    .read_str_error:
        ; If we reach here, it means an error occurred during the read syscall (rax is negative). We can handle the error as needed, but for now, we will just return with rax containing the number of bytes read (which will be negative in case of an error).
        ret

    .read_str_done:
        ret                             ; Return from the function, with rax containing the number of bytes read

%endif; STRUTILS_ASM
