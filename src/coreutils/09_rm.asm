; rm.asm

%define SYS_WRITE       1
%define SYS_EXIT        60
%define SYS_UNLINK      87

%define FD_STDERR       2

section .data
    err_msg db "Error deleting file", 0xA
    err_len $ - err_msg

    usage_msg db "Usage: rm <file>", 0xA
    usage_len equ $ - usage_msg

section .text
    global _start

_start:
    ; Check argc
    mov rax, [rsp]
    cmp rax, 2
    jl .usage

    ; Load argv[1]
    mov rdi, [rsp + 8 + 8]      ; Pointer to argv[1] (filename)

    ; unlink(filename)
    mov rax, SYS_UNLINK
    syscall

    ; Check error
    test rax, rax
    js .error               ; if rax is negative (< 0), then jump to error

    ; exit 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.usage:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel usage_msg]
    mov rdx, usage_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.error:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel err_msg]
    mov rdx, err_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
