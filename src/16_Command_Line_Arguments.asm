; Command-Line Arguments

; When you run a program like `./program arg1 arg2 arg3`, the operating system setups up the stack with:

; Stack Layout at _start:
; ┌─────────────────────┐  ← RSP
; │  argc (count)       │  [rsp]     = number of arguments
; ├─────────────────────┤
; │  argv[0] (pointer)  │  [rsp+8]   = program name
; ├─────────────────────┤
; │  argv[1] (pointer)  │  [rsp+16]  = first argument
; ├─────────────────────┤
; │  argv[2] (pointer)  │  [rsp+24]  = second argument
; ├─────────────────────┤
; │  ...                │
; ├─────────────────────┤
; │  NULL               │  End of argv
; ├─────────────────────┤
; │  envp[0] (pointer)  │  Environment variables
; │  ...                │
; └─────────────────────┘

; Each `argv[i]` is a pointer to a null-terminalted string

; Simple Calculator

section .data
    usage_msg db 'Usage: ./calc <num1> <op> <num2>', 0xA
    usage_msg_len equ $ - usage_msg

    error_msg db 'Error: Invalid operator (use +, -, *, /)', 0xA
    error_msg_len equ $ - error_msg

    result_msg db 'Result: ', 0xA
    result_msg_len equ $ - result_msg
    
    newline db 0xA

section .bss
    num1 resq 1
    num2 resq 1
    result resq 1
    digit_buffer resb 20

section .text
    global _start

_start:
    ; Check argument count (need exactly 4: program + 3 args)
    mov rax, [rsp]
    cmp rax, 4
    jne .usage_error

    ; Parse first number (argv[1])
    mov rdi, [rsp + 8 + 8]
    call str_to_int
    mov [num1], rax

    ; Get operator (argv[2])
    mov r12, rsp[8 + 8 * 2]   ; Pointer to operator string
    mov r12b, [r12]           ; First character of operator

    ; Parse second number (argv[3])
    mov rdi, [rsp + 8 + 8 * 3]
    call str_to_int
    mov [num2], rax

    ; Perform operation
    mov rax, [num1]
    mov rbx, [num2]

    cmp r12b, '+'
    je .add
    cmp r12b, '-'
    je .sub
    cmp r12b, '*'
    je .mul
    cmp r12b, '/'
    je .div

    ; Invalid Operator
    jmp .operator_error

    .add:
        add rax, rbx
        jmp .print_result

    .sub:
        sub rax, rbx
        jmp .print_result
    
    .mul:
        imul rax, rbx
        jmp .print_result
    
    .div:
        xor rdx, rdx,
        idiv rbx
        jmp .print_result

    .print_result:
        mov [result], rax

        ; Print "Result: "
        mov rax, 1
        mov rdi, 1
        mov rsi, result_msg
        mov rdx, result_msg_len
        syscall

        ; Print result
        mov rax, [result]
        call print_number

        ; Print newline
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall

        jmp .exit

    .usage_error:
        mov rax, 1
        mov rdi, 2      ; stderr
        mov rsi, usage_msg
        mov rdx, usage_msg_len
        syscall

        mov rax, 60
        mov rdi, 1
        syscall

    .operator_error:
        mov rax, 1
        mov rdi, 2
        mov rsi, error_msg
        mov rdx, error_msg_len
        syscall

        mov rax, 60
        mov rdi, 1
        syscall

    .exit:
        mov rax, 60
        xor rdi, rdi
        syscall

; Function: str_to_int
; Input: RDI = string pointer
; Output: RAX = integer
str_to_int:
    xor rax, rax        ; Result
    xor rcx, rcx        ; Sign Flag

    ; Check for negative
    cmp byte [rdi], '-'
    jne .parse
    inc rdi
    mov rcx, 1

    .parse:
        movzx rbx, byte [rdi]
        test rbx, rbx
        jz .done

        cmp bl, '0'
        jb .done
        cmp bl, '9'
        ja .done

        sub bl, '0'
        imul rax, 10
        add rax, rbx

        inc rdi
        jmp .parse

    .done:
        test rcx, rcx
        jz .positive
        neg rax

    .positive:
        ret

print_number:
        ; Handle negative numbers
        test rax, rax
        jns .positive

        push rax
        mov rax, 1
        mov rdi, 1
        mov byte [digit_buffer], '-'
        mov rsi, digit_buffer
        mov rdx, 1
        syscall
        pop rax
        neg rax

    .positive:
        mov rbx, 10
        xor rcx, rcx
        test rax, rax
        jnz .convert
        mov byte [digit_buffer], '0'
        mov rcx, 1
        jmp .print

    .convert:
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        test rax, rax
        jnz .convert

        xor rbx, rbx

    .pop:
        pop rax
        mov [digit_buffer + rbx], al
        inc rbx
        dec rcx
        jnz .pop

    .print:
        mov rax, 1
        mov rdi, 1
        mov rsi, digit_buffer
        mov rdx, rbx
        syscall
        ret
