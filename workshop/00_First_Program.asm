; The simplest possible asm program. It simply exists with a status code

section .text
    global _start

_start:
    mov rax, 60     ; 60 is syscall number for exit
    mov rdi, 07     ; The status code number to exit with
    syscall         ; ask kernel to exit

; `mov` instruction moves data into register
; `rax` holds the syscall number (60 for exit)
; `rdi` holds the first argument (exit code)
; `syscall` transfers control to the kernel
