; false - do nothing, unsuccessfully

section .text
    global _start

_start:
    mov rax, 60     ; syscall: exit
    mov rdi, 1      ; exit status code: 1
    syscall
