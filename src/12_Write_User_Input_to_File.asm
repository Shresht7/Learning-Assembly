; Write User Input to a File

section .data
    prompt db 'Enter text to save: ', 0
    prompt_len equ $ - prompt
    
    filename db 'user_input.text', 0
    
    success db 'Saved to file!', 0xA
    success_len equ $ - success
    
section .bss
    input resb 256      ; Reserve 256 bytes for the input

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 256
    syscall

    mov r12, rax        ; Save input length

    ; Open file
    mov rax, 2
    mov rdi, filename
    mov rsi, 0x241      ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 0644o
    syscall

    mov r13, rax        ; Save file descriptor

    ; Write to file
    mov rax, 1          ; syscall write
    mov rdi, r13        ; Write to saved file-descriptor
    mov rsi, input      ; write input buffer
    mov rdx, r12        ; use saved length
    syscall

    ; Close file
    mov rax, 3
    mov rdi, r13
    syscall

    ; Print success
    mov rax, 1
    mov rdi, 1
    mov rsi, success
    mov rdx, success_len
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
