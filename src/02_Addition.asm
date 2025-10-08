; Add two numbers and print the result

; Constants
section .data
    result db '0', 0xA          ; Will store results + newline

; Code
section .text
    global _start

_start:
    ; Add two numbers
    mov rax, 5                  ; First Number in RAX
    mov rbx, 3                  ; Second Number in RBX
    add rax, rbx                ; rax = rax + rbx = 5 + 3 = 8

    ; Convert to ASCII (only works for 0-9)
    add rax, '0'                ; '0' in ASCII is 48, so 8 becomes 56 ('8')

    ; Store result
    mov [result], al            ; al is lower 8 bits of rax

    ; Print Results
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: 1 for stdout
    mov rsi, result             ; buffer: contents to write out
    mov rdx, 2                  ; Length: 2 bytes (digit + newline)
    syscall                     ; Ask the kernel to print

    ; Exit
    mov rax, 60                 ; syscall: exit
    xor rdi, rdi                ; Status Code 0 for Success
    syscall                     ; Ask the kernel to exit


; `add` instruction performs addition
; Multiple registers were used: `rax`, `rbx` etc
; `al` is the lower 8 bits of `rax`
; `[result]` means "memory at address result"
; ASCII arithmetic: '0' + number = digit character in ASCII

