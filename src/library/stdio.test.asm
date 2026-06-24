%include "src/library/stdio.asm"
%include "src/library/strutils.asm"

section .data

    ; Newline character for printing
    newline db 0xA
    newline_len equ 1

    ; Define messages to be printed
    msg_hello_world db 'Hello, World!', 0xA, 0
    msg_hello_world_len equ $ - msg_hello_world

    msg_hello db 'Hello, ', 0
    msg_hello_len equ $ - msg_hello

    msg_enter_name db 'Enter your name: ', 0
    msg_enter_name_len equ $ - msg_enter_name

    msg_enter_email db 'Enter your email: ', 0
    msg_enter_email_len equ $ - msg_enter_email

section .bss
    ; Reserve space for the user's name and email inputs
    name_buffer resb 50
    email_buffer resb 50

section .text
global _start

_start:
    ; Print "Hello, World!" to stdout
    PRINT msg_hello_world

    ; Prompt the user to enter their name
    PRINT msg_enter_name

    ; Read the user's name into the buffer
    mov rdi, name_buffer                    ; Pointer to the buffer
    mov rsi, 50                             ; Size of the buffer
    call read_str                           ; Read input from stdin

    ; Print a greeting with the user's name
    PRINT msg_hello
    mov rdi, name_buffer                    ; Pointer to the buffer containing the user's name
    call print_str                          ; Print the user's name
    PRINT newline

    ; Prompt the user to enter their email using the macro
    PRINT_STR msg_enter_email

    ; Read the user's email into the buffer using the macro
    READ_STR email_buffer, 50
    PRINT_STR email_buffer
    PRINT newline

    ; Exit the program successfully
    EXIT EXIT_SUCCESS
