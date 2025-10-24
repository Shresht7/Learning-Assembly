; pwd.asm
; The present working directory

%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETCWD 79

%define FD_STDOUT 1
%define FD_STDERR 2

section .data
    err_msg db "Error getting cwd", 10
    err_len equ $ - err_msg

    newline db 10

section .bss
    buf resb 1024           ; 1KB buffer for the path


section .text
    global _start

_start:
    mov rax, SYS_GETCWD     ; Syscall: Present Working Directory
    lea rdi, [rel buf]      ; The buffer to store the pwd into
    mov rsi, 1024           ; The number of bytes to read
    syscall

    test rax, rax
    js .error           ; if rax < 0 (negative), error

    ; On success, rax = pointer to the buffer
    ; Write string to stdout

    ; Find string length (null-terminated)
    xor rcx, rcx
.count_loop:
    cmp byte [rdi + rcx], 0     ; Check if we've reached null-terminator
    je .done_count
    inc rcx
    jmp .count_loop
.done_count:
    ; write(STDOUT, buf, length)
    mov rax, SYS_WRITE          ; Syscall: Write
    mov rdi, FD_STDOUT          ; File Descriptor: STDOUT
    lea rsi, [rel buf]          ; The buffer to print
    mov rdx, rcx                ; The length of the string to print in byte count
    syscall

    ; Print newline
    mov rax, SYS_WRITE          ; Syscall: Write
    mov rdi, FD_STDOUT          ; File Descriptor: STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.error:
    mov rax, SYS_WRITE          ; Syscall: Write
    mov rdi, FD_STDERR          ; File Descriptor: STDERR
    lea rsi, [rel err_msg]      ; The buffer to print
    mov rdx, err_len            ; The number of bytes to print
    syscall

    ; exit 1
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
