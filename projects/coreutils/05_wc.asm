; wc - print newline, word and byte counts for each file
; usage: wc [file]...

section .data
    space db ' '
    newline db 0xA

section .bss
    buffer resb 8192
    lines resq 1
    words resq 1
    bytes resq 1
    in_word resb 1

section .text
    global _start

_start:
    pop r12             ; r12 = argc
    pop rsi             ; Skip argv[0]
    dec r12

    test r12, r12
    jz .count_stdin     ; if no args, read from stdin

.file_loop:
    pop r15             ; r15 = filename

    ; open(filename, O_RDONLY)
    mov rax, 2          ; syscall: read
    mov rdi, r15        ; file descriptor
    xor rsi, rsi
    xor rdx, rdx
    syscall

    test rax, rax
    js .next_file       ; Skip on error

    mov r13, rax        ; r13 = fd
    call .count_fd
    call .print_counts

    ; Print filename
    mov rsi, r15
    call .print_str

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; close(fd)
    mov rax, 3
    mov rdi, r13
    syscall

.next_file:
    dec r12
    test r12, r12
    jnz .file_loop
    jmp .exit

.count_stdin:
    xor r13, r13
    call .count_fd
    call .print_counts
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    jmp .exit

; Count lines, words, bytes from fd in R13
.count_fd:
    ; Initialize counters
    mov qword [lines], 0
    mov qword [words], 0
    mov qword [bytes], 0
    mov byte [in_word], 0

.read_loop:
    mov rax, 0
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 8192
    syscall

    test rax, rax
    jle .count_done

    mov r14, rax            ; bytes read
    add [bytes], r14

    ; Process each byte
    xor rcx, rcx

.byte_loop:
    cmp rcx, r14
    jge .read_loop

    movzx rax, byte [buffer + rcx]

    ; Check for newline
    cmp al, 10
    jne .not_newline
    inc qword [lines]

.not_newline:
    ; Check if whitespace
    cmp al, 32              ; space
    je .is_space
    cmp al, 9               ; tab
    je .is_space
    cmp al, 10              ; newline
    je .is_space
    cmp al, 13              ; carriage return
    je .is_space

    ; Not whitespace - we're in a word
    cmp byte [in_word], 0
    jne .still_in_word

    inc qword [words]
    mov byte [in_word], 1

.still_in_word:
    inc rcx
    jmp .byte_loop

.is_space:
    mov byte [in_word], 0
    inc rcx
    jmp .byte_loop

.count_done:
    ret

; Print counts in format: lines words bytes
.print_counts:
    mov rax, [lines]
    call .print_num

    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    mov rax, [words]
    call .print_num

    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    mov rax, [bytes]
    call .print_num

    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    ret


.print_num:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rcx, 10
    lea rdi, [rbp - 1]
    mov byte [rdi], 0

.num_loop:
    dec rdi
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    test rax, rax
    jnz .num_loop

    ; Calculate length
    lea rsi, [rbp - 1]
    sub rsi, rdi


    ; write
    mov rax, 1
    push rdi
    mov rdi, 1
    pop rsi
    mov rdx, rsi
    lea rsi, [rbp - 1]
    sub rdx, rsi
    inc rdx
    mov rsi, rdi
    pop rdi
    push rdi
    syscall

    leave
    ret

.print_str:
    mov rdi, rsi
    xor rdx, rdx

.strlen_loop:
    cmp byte [rdi + rdx], 0
    je .strlen_done
    inc rdx
    jmp .strlen_loop

.strlen_done:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; FIXME: Doesnt Print Numbers!
