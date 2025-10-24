; sleep.asm

%define SYS_WRITE       1
%define SYS_NANOSLEEP   35
%define SYS_EXIT        60

%define FD_STDOUT       1
%define FD_STDERR       2

section .bss
    ts resq 2           ; tv_sec, tv_nsec
    buf resb 32         ; Optional buffer for string conversion

section .data
    err_msg db "Usage: sleep <seconds>", 10
    err_len equ $ - err_msg

section .text
    global _start

_start:
    ; Check argc
    mov rax, [rsp]          ; rsp points to argc at program start
    cmp rax, 2
    jl .usage               ; Needs argv[1]

    ; Load argv[1]
    mov rsi, [rsp + 8 + 8]  ; argv[1] pointer

    ; Convert string to integer (decimal)
    xor rbx, rbx            ; Result
    .convert_loop:
        mov al, [rsi]       ; al <- argv[1]
        cmp al, 0           ; Check null terminator
        je .converted       ; if yes, jump to conclusion
        
        sub al, '0'         ; subtract the ascii value of the character '0' to get offset
        cmp al, 9
        ja .usage

        imul rbx, rbx, 10
        add rbx, rax
        inc rsi
        jmp .convert_loop   ; Loop over
    .converted:
        ; Store seconds in ts.tv_sec
        mov [ts], rbx
        mov qword [ts + 8], 0       ; tv_nsec = 0

        ; nanosleep(&ts, NULL)
        mov rax, SYS_NANOSLEEP
        lea rdi, [ts]
        xor rsi, rsi                ; NULL for remainder
        syscall

        ; Exit 0
        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

.usage:
    ; Write usage message
    mov rax, SYS_WRITE
    mov rdi, FD_STDERR
    lea rsi, [rel err_msg]
    mov rdx, err_len
    syscall

    ; Exit 1
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

