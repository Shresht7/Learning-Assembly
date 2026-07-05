; cp.asm

%define SYS_READ    0
%define SYS_WRITE   1
%define SYS_OPEN    2
%define SYS_CLOSE   3
%define SYS_EXIT    60

%define O_RDONLY    0
%define O_WRONLY    1
%define O_CREAT     64
%define O_TRUNC     512
%define FILE_MODE   420     ; 0644 decimal

%define FD_STDERR   2

section .data
    err_msg db "Error copying file", 0xA
    err_len equ $ - err_msg

    usg_msg db "Usage: cp <source> <destination>", 0xA
    usg_len equ $ - usg_msg

section .bss
    buf resb 4096           ; 4 KB Buffer

section .text
    global _start

_start:
    ; Check argc
    mov rax, [rsp]          ; argc
    cmp rax, 3
    jl .usage

    ; Load argv[1] and argv[2]
    mov rsi, [rsp + 16]     ; src pointer
    mov rdi, [rsp + 24]     ; dst pointer

    ; open(src, O_RDONLY)
    mov rax, SYS_OPEN
    push rdi
    mov rdi, rsi
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    pop rdi

    test rax, rax
    js .error
    mov r12, rax            ; src fd

    ; open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0644)
    mov rax, SYS_OPEN
    mov rdi, rdi            ; dest pointer
    mov rsi, O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, FILE_MODE
    syscall

    test rax, rax
    js .error
    mov r13, rax            ; dest fd

.copy_loop:
    ; read(src, buf, 4096)
    mov rax, SYS_READ
    mov rdi, r12            ; file descriptor: source file
    lea rsi, [buf]
    mov rdx, 4096
    syscall

    cmp rax, 0              ; No bytes read
    je .done                ; EOF
    js .error               ; Error
    mov rbx, rax            ; rbx <- rax (Number of bytes read)

    ;write(dst, buf, rbx)
    mov rax, SYS_WRITE
    mov rdi, r13            ; file descriptor: dest file
    lea rsi, [buf]
    mov rdx, rbx
    syscall

    js .error

    jmp .copy_loop          ; Loop over until EOF or Error

.done:
    ; close files
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall
    mov rax, SYS_CLOSE
    mov rdi, r13
    syscall

    ; exit 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.usage:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel usg_msg]
    mov rdx, usg_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.error:
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    mov rsi, [rel err_msg]
    mov rdx, err_len
    syscall
