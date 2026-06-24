%ifndef SYSCALLS_ASM
%define SYSCALLS_ASM

; --------
; SYSCALLS
; --------

; Syscalls
SYSCALL_READ    equ 0
SYSCALL_WRITE   equ 1
SYSCALL_EXIT    equ 60

; File Descriptors
STDIN           equ 0
STDOUT          equ 1
STDERR          equ 2

; Exit Status Codes
EXIT_SUCCESS    equ 0
EXIT_FAILURE    equ 1

; WRITE macro to write a message to a file
%macro WRITE 3
    mov rax, SYSCALL_WRITE          ; syscall: write
    mov rdi, %1                     ; file descriptor: %1 (e.g., STDOUT)
    mov rsi, %2                     ; buffer: pointer to the message
    mov rdx, %3                     ; count: length of the message
    syscall                         ; execute syscall
%endmacro

; READ macro to read input from a file
%macro READ 3
    mov rax, SYSCALL_READ           ; syscall: read
    mov rdi, %1                     ; file descriptor: %1 (e.g., STDIN)
    mov rsi, %2                     ; buffer: pointer to the buffer
    mov rdx, %3                     ; count: number of bytes to read
    syscall                         ; execute syscall
%endmacro

; PRINT macro to print a message to stdout
%macro PRINT 1
    mov rax, SYSCALL_WRITE          ; syscall: write
    mov rdi, STDOUT                 ; file descriptor: stdout
    mov rsi, %1                     ; buffer: pointer to the message
    mov rdx, %1_len                 ; count: length of the message
    syscall                         ; execute syscall
%endmacro

; ERROR macro to print an error message to stderr
%macro ERROR 1
    mov rax, SYSCALL_WRITE          ; syscall: write
    mov rdi, STDERR                 ; file descriptor: stderr
    mov rsi, %1                     ; buffer: pointer to the error message
    mov rdx, %1_len                 ; count: length of the error message
    syscall                         ; execute syscall
%endmacro

; EXIT macro to exit the program with a given status code
%macro EXIT 1
    mov rax, SYSCALL_EXIT           ; syscall: exit
    mov rdi, %1                     ; status: exit code
    syscall                         ; execute
%endmacro

; DEFINE_STR macro to define a string in the data section
%macro DEFINE_STR 2+
    %1: db %2
    %1_len: equ $ - %1
%endmacro


%endif; SYSCALLS_ASM
