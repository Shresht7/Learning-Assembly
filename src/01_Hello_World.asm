; Prints "Hello World" to the screen

; Constants
section .data
    msg db 'Hello World!', 0xA  ; Define Bytes (db) msg as 'Hello World!'. 0xA is newline
    len equ $ - msg             ; Calculate length

; Code
section .text
    global _start

_start:
    ; write(fd, buffer, count)
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: 1 for stdout
    mov rsi, msg                ; buffer: pointer to our string
    mov rdx, len                ; count: number of bytes
    syscall                     ; Ask kernel to execute syscall: write

    ; exit(status)
    mov rax, 60                 ; syscall: exit
    xor rdi, rdi                ; status: 0 (xor with itself to zero out)
    syscall                     ; Ask kernel to execute syscall: exit

; `section .data` is where we store constants
; `db` (define byte): creates a byte array
; `equ`: defines a constant (like `#define`)
; `$ - msg`: current position minus msg address = length of byte array
; Memory addresses go in registers (msg is an address)
