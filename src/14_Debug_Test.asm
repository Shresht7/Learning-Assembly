; Program with intentional bugs for debugging practice

section .data
    array dq 10, 20, 30, 40, 50
    array_len equ 5

    result_msg db 'Sum: ', 0
    result_msg_len equ $ - result_msg

    newline db 0xA

section .bss
    sum resq 1
    print_buffer resb 20

section .text
    global _start

_start:
    ; Calculate the sum of array
    mov rdi, array
    mov rsi, array_len
    call calculate_sum

    mov [sum], rax

    ; Print result
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall

    mov rax, [sum]
    call print_number

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; Function: calculate_sum
; Input: RDI = array pointer, RSI = length
; Output: RAX = sum
calculate_sum:
    xor rax, rax    ; sum = 0
    xor rcx, rcx    ; index = 0
    .loop:
        cmp rcx, rsi
        jge .done

        ; Add current element
        add rax, [rdi + rcx*8]

        inc rcx
        jmp .loop
    .done:
        ret

print_number:
    mov rbx, 10
    xor rcx, rcx

    test rax, rax
    jnz .convert
    mov byte [print_buffer], '0'
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
    mov [print_buffer + rbx], al
    inc rbx
    dec rcx
    jnz .pop

.print:
    mov rax, 1
    mov rdi, 1
    mov rsi, print_buffer
    mov rdx, rbx
    syscall
    ret

