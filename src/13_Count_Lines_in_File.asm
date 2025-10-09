; Count the number of lines in a file

section .data
    filename db 'test_output.txt', 0
    
    msg db 'Number of lines: ', 0
    msg_len equ $ - msg

    newline db 0xA

section .bss
    buffer resb 1
    count resq 1
    digit resb 1

section .text
    global _start

_start:
    ; Open File
    mov rax, 2
    mov rdi, filename
    mov rsi, 0      ; O_RDONLY
    syscall

    test rax, rax
    js .error

    mov r12, rax        ; Save File descriptor
    xor r13, r13        ; Initialize Line Counter = 0    

    .read_loop:
        ; Read one byte
        mov rax, 0
        mov rdi, r12
        mov rsi, buffer
        mov rdx, 1
        syscall

        test rax, rax
        jz .done            ; EOF

        ; Check if it is a newline
        cmp byte [buffer], 0xA
        jne .read_loop

        inc r13             ; Found a new line
        jmp .read_loop

    .done:
        ; Close file
        mov rax, 3
        mov rdi, r12
        syscall

        ; Print message
        mov rax, 1
        mov rdi, 1
        mov rsi, msg
        mov rdx, msg_len
        syscall

        ; Print count (assuming < 10)
        mov rax, r13
        add rax, '0'
        mov [digit], al

        mov rax, 1
        mov rdi, 1
        mov rsi, digit
        mov rdx, 1
        syscall
        
        ; Print newline
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall

    .error:
        mov rax, 60
        xor rdi, rdi
        syscall


        
