%include "src/library/stdio.asm"
%include "src/library/strutils.asm"

section .data
    newline db 0xA
    newline_len equ 1

    msg_hello_world db 'Hello, World!', 0xA, 0
    msg_hello_world_len equ $ - msg_hello_world

    msg_hello db 'Hello, ', 0
    msg_hello_len equ $ - msg_hello

    msg_enter_name db 'Enter your name: ', 0
    msg_enter_name_len equ $ - msg_enter_name

section .bss
    name_buffer resb 50

section .text
global _start

_start:
    ; Print "Hello, World!" to stdout
    PRINT msg_hello_world

    ; Prompt the user to enter their name
    PRINT msg_enter_name

    ; Read the user's name into the buffer
    mov rdi, name_buffer            ; Pointer to the buffer
    mov rsi, 50                     ; Size of the buffer
    call read_str                   ; Read input from stdin
    mov r8, rax                      ; Store the number of bytes read in r8

    ; Print a greeting with the user's name
    PRINT msg_hello
    mov rdi, name_buffer            ; Pointer to the buffer containing the user's name
    call print_str                  ; Print the user's name
    PRINT newline

    ; Exit the program successfully
    EXIT EXIT_SUCCESS
