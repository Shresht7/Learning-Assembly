; Call a function to print a character

; Constants
section .data
    newline db 0xA

; Code
section .text
    global _start

_start:
    mov rdi, 'A'        ; Argument: character to print
    call print_char

    mov rdi, 'B'        ; New Argument
    call print_char

    mov rdi, 'C'
    call print_char

    ; Print Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; Function: print_char
; Input: rdi = character to print
; Returns: nothing
print_char:
    push rdi        ; Save character on stack

    mov rax, 1      ; syscall: write
    mov rdi, 1      ; stdout
    mov rsi, rsp    ; pointer to character (top of stack)
    mov rdx, 1      ; 1 byte
    syscall

    pop rdi         ; Cleanup stack
    ret             ; Return to caller

; `call` pushes return address and jumps to function
; `ret` pops return address and returns it
; `push`: Puts value on the stack
; `pop`: Removes value from the stack
; Stack grows downwards (push decreases `rsp`)
; `rsp` is the Stack pointer
