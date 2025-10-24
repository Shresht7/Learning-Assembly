; touch.asm

%define SYS_WRITE   1
%define SYS_OPEN    2
%define SYS_CLOSE   3
%define SYS_EXIT    60

%define O_CREAT     64
%define O_WRONLY    1
%define FILE_MODE   420     ; 0644 decimal

%define FD_STDERR   2

section .data
    err_msg db "Error creating file", 0xA
    err_len equ $ - err_msg

    usage_msg db "Usage: touch <file>", 0xA
    usage_len equ $ - usage_msg

section .text
    global _start

_start:
    ; argc
    mov rax, [rsp]      ; rsp is the pointer to argc when the program starts
    cmp rax, 2
    jl .usage           ; argv[1] must exist (filename)

    ; Load argv[1]
    mov rdi, [rsp + 8 + 8]  ; rdi now points to the *filename

    ; open(filename, O_CREAT | O_WRONLY, 0644)
    mov rax, SYS_OPEN
    mov rsi, O_CREAT | O_WRONLY
    mov rdx, FILE_MODE
    syscall

    test rax, rax
    js .error           ; rax is negative if error

    mov rbx, rax        ; save file descriptor for later

    ; close(fd)
    mov rax, SYS_CLOSE
    mov rdi, rbx
    syscall

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
