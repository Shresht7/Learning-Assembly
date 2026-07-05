; Read and Echo a full line of input

; Constants
section .data
    prompt db 'Enter your name: ', 0
    prompt_len equ $ - prompt

    hello db 'Hello, ', 0
    hello_len equ $ - hello

    exclaim db '!', 0xA, 0
    exclaim_len equ $ - exclaim

; Uninitialized Data
section .bss
    buffer resb 100     ; Buffer for input (100 bytes)
    input_len resq 1    ; Store actual length read

; Code
section .text
    global _start

_start:
    ; Print Prompt
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; fd: stdout
    mov rsi, prompt     ; buffer to write
    mov rdx, prompt_len ; length in bytes to write
    syscall

    ; Read Input
    mov rax, 0          ; syscall: read
    mov rdi, 0          ; fd: stdin
    mov rsi, buffer     ; buffer to read into
    mov rdx, 100        ; max length of bytes to read
    syscall
    mov [input_len], rax    ; Save how many bytes we read

    ; The input includes the newline, let's remove it
    dec rax                         ; Decrease the length by 1
    mov byte [buffer + rax], 0      ; Replace newline with null
    mov [input_len], rax            ; Update length

    ; Print Greeting
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; fd: stdout
    mov rsi, hello      ; buffer to write
    mov rdx, hello_len  ; bytes to write
    syscall

    ; Print the Name
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd: stdout
    mov rsi, buffer         ; buffer to write
    mov rdx, [input_len]    ; no of bytes to write
    syscall

    ; Print Exclamation Mark !
    mov rax, 1
    mov rdi, 1
    mov rsi, exclaim
    mov rdi, exclaim_len
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; `read` syscall returns the number of bytes read in `RAX`
; Input includes the newline character `\n`
; We replace it with null (`0`) to make a proper C-style string
