; Read and echo user input

; Constants
section .data
    prompt db 'Enter a character: '
    prompt_len equ $ - prompt

    echo db 'You entered: '
    echo_len equ $ - echo

    newline db 0xA

section .bss
    input resb 1            ; Reserve 1 byte for input

section .text
    global _start

_start:
    ; Print the Prompt
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, prompt         ; buffer
    mov rdx, prompt_len     ; buffer length
    syscall

    ; Read input
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; file descriptor 0 for stdin
    mov rsi, input          ; buffer to store input
    mov rdx, 1              ; Length to read: read 1 byte
    syscall

    ; Print echo message
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, echo           ; buffer
    mov rdx, echo_len       ; length of buffer
    syscall
    
    ; Print the input
    mov rax, 1              ; syscall; write
    mov rdi, 1              ; stdout
    mov rsi, input          ; buffer
    mov rdx, 1              ; 1 byte length
    syscall

    ; Print newline
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, newline        ; buffer
    mov rdx, 1              ; length
    syscall

    ; Exit
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; Status Code Zero
    syscall


; `section .bss`: Uninitialized Data (doesn't take up space in the executable)
; `resb`: Reserve bytes
; `read`: syscall 0: read from file-descriptor
; file-descriptors: 0 for stdin, 1 for stdout, 2 for stderr
