; The `rdrand` instruction is used to generate random numbers using the CPU's hardware random number generator.
; It is unique because it does not rely on software algorithms, but instead pulls thermal noise from the processsor's silicon to generate entropy.

section .data
    msg db 'Random number: ', 0
    msg_len equ $ - msg
    newline db 0xA

section .bss
    random_number resb 1   ; To store the ASCII character

section .text
    global _start

_start:
    ; Get hardware random number using RDRAND
retry:
    rdrand rax            ; Attempt to get a random number
    jnc retry              ; If the carry flag is not set, the random number is not valid, so retry

    ; Convert the random number to an ASCII character (0-9)
    ; We can use modulo 10 to get a number between 0 and 9,
    ; and then add '0' (0x30) to convert it to the corresponding ASCII character
    
    xor rdx, rdx            ; Clear rdx for division
    mov rcx, 10             ; Divisor for modulo operation
    div rcx                 ; rax now contains the quotient, rdx contains the remainder

    inc rdx                 ; Increment remainder to get a number between 1 and 10
    add rdx, '0'            ; Convert to ASCII character
    mov [random_number], dl ; Store the ASCII character in our buffer

    ; Print the message
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    lea rsi, [msg]          ; pointer to the message
    mov rdx, msg_len        ; length of the message
    syscall

    ; Print the random number
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    lea rsi, [random_number]    ; pointer to the random number
    mov rdx, 1                  ; length of the random number (1 byte)
    syscall

    ; Print a newline
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    lea rsi, [newline]     ; pointer to the newline character
    mov rdx, 1              ; length of the newline character
    syscall

    ; Exit the program
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; exit code 0
    syscall
