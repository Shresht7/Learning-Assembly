; Compare two numbers

; Constants
section .data
    msg_greater db 'First is greater', 0xA
    len_greater equ $ - msg_greater

    msg_less db 'Second is greater', 0xA
    len_less equ $ - msg_less

    msg_equal db 'They are equal', 0xA
    len_equal equ $ - msg_equal

; Code
section .text
    global _start

_start:
    mov rax, 7          ; First Number
    mov rbx, 5          ; Second Number

    cmp rax, rbx        ; Compare rax and rbx
    jg greater          ; Jump if Greater
    je equal            ; Jump if Equal
    jl less             ; Jump if Less

greater:
    mov rsi, msg_greater
    mov rdx, len_greater
    jmp print

equal:
    mov rsi, msg_equal
    mov rdx, len_equal
    jmp print

less:
    mov rsi, msg_less
    mov rdx, len_less
    jmp print

print:
    mov rax, 1          ; Syscall: write
    mov rdi, 1          ; file descriptor: 1 for stdout
    syscall             ; rsi and rdx are already set. Call the kernel

    ; Exit
    mov rax, 60         ; Syscall: exit
    xor rdi, rdi        ; Status Code 0 for Success
    syscall

; `cmp` compares two values (set CPU flags)
; `jg` (jump if greater), `je` (jump if equal), and `jl` (jump if less)
; `jmp` unconditionally jump to a label
; Labels (like `greater:`) mark positions in the code that can be jumped to

; Jump Instructions
; `je` / `jz`: equal / zero
; `jne` / `jnz`: not equal / not zero
; `jg` / `jnle`: greater / not less or equal (signed)
; `jl` / `jnge`: less / not greater or equal (signed)
; `ja` / `jnbe`: above / not below or equal (unsigned)
; `jb` / `jnae`: below / not above or equal (unsigned)
