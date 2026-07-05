; true - do nothing, successfully

section .text
    global _start

_start:
    mov rax, 60     ; syscall: exit
    xor rdi, rdi    ; exit status code: 0 (zero out with xor)
    syscall
