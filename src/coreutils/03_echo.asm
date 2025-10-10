; echo - display a line of text
; usage: echo [string] ...

section .data
    space db ' '
    newline db 0xA      ; Or decimal number 10

section .text
    global _start

_start:
    pop r12             ; r12 = argc
    pop rsi             ; skip argv[0]
    dec r12             ; argc - 1

    ; Check if there are more than one argument
    test r12, r12
    jz .print_newline   ; If no arguments, just print newline

    .arg_loop:
        pop rsi         ; rsi = argv[i]

        ; Calculate string length
        mov rdi, rsi
        xor rdx, rdx    ; Zero out the counter
        .strlen:
            cmp byte [rdi + rdx], 0     ; Check if we've hit the null terminator
            je .strlen_done             ; If true, then jump to strlen_done
            ; Otherwise
            inc rdx                     ; Increment Counter
            jmp .strlen                 ; Loop over
        
        .strlen_done:
            ; write(STDOUT, str, len)
            mov rax, 1                  ; syscall: write
            mov rdi, 1                  ; file descriptor: stdout
            ; rdi and rdx should already be set in place
            syscall

            dec r12
            test r12, r12               ; if this was the last argument, print newline
            jz .print_newline

            ; Otherwise, continue by printing space between arguments
            mov rax, 1                  ; syscall: write
            mov rdi, 1                  ; file-descriptor: stdout
            mov rsi, space              ; buffer to write
            mov rdx, 1                  ; bytes to write
            syscall

            jmp .arg_loop               ; Loop over the argument loop

        .print_newline:
            mov rax, 1                  ; syscall: write
            mov rdi, 1                  ; file descriptor: stdout
            mov rsi, newline            ; buffer to write
            mov rdx, 1                  ; bytes to write
            syscall

    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; status code 0
    syscall                
