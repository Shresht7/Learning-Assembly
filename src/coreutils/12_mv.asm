; mv.asm

%define SYS_WRITE   1
%define SYS_EXIT    60
%define SYS_RENAME  82

%define FD_STDERR   2

%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, $1
    syscall
%endmacro


section .data
    err_msg db "Error moving file", 0xA
    err_len equ $ - err_msg

    usg_msg db "Usage: mv <source> <destination>", 0xA
    usg_len equ $ - usg_msg

section .text
    global _start

_start:
    ; Check argc
    mov rax, [rsp]
    cmp rax, 3
    jl .usage

    ; Load argv[1] and argv[2]
    mov rdi, [rsp + 16]         ; src pointer
    mov rsi, [rsp + 24]         ; dst pointer

    ; rename(src, dst)
    mov rax, SYS_RENAME
    syscall

    test rax, rax
    js .error

    exit 0

.usage:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel usg_msg]
    mov rdx, usg_len
    syscall

    exit 1

.error:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel err_msg]
    mov rdx, err_len
    syscall

    exit 1
