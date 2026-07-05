; yes - output a string repeatedly until killed
; usage: ./yes [String]

section .data
    default_str db 'y', 0xA     ; default: 'y\n'
    default_str_len equ $ - default_str

section .bss
    buffer resb 1024            ; Reserve 1024 bytes for buffer for custom string + newline

section .text
    global _start

_start:
    ; Get argc from stack
    pop rcx                     ; rcx = argc
    pop rsi                     ; rsi = argv[0] (program name)

    ; if argc == 1
        cmp rcx, 1              ; if argc == 1, use default 'y'
        je .use_default
    ; Otherwise, use custom string from argv[1]
        pop rsi                 ; rsi = argv[1]

    ; Calculate string length
    mov rdi, rsi                ; Store string pointer in rdi
    xor rcx, rcx                ; zero out rcx. Counter = 0

    .strlen:
        cmp byte [rdi + rcx], 0 ; Check if we've hit the null terminator
        je .strlen_done         ; Jump to strlen_done if yes
        ; Otherwise
        inc rcx                 ; Increment counter by 1
        jmp .strlen             ; Repeat loop

    .strlen_done:
        ; Copy string to buffer
        mov rdi, buffer
        rep movsb               ; Copy rcx bytes from rsi to rdi

        ; Add newline
        mov byte [rdi], 0xA
        inc rcx

        mov rsi, buffer
        mov rdx, rcx            ; rdx = length
        jmp .loop    

    .use_default:
        mov rsi, default_str
        mov rdx, default_str_len

    .loop:
        ; write(STDOUT, str, len)
        mov rax, 1              ; syscall: write
        mov rdi, 1              ; file descriptor: stdout
        ; rsi and rdx should already be set
        syscall

        ; Check for error (write returns -errno on error)
        test rax, rax
        js .exit                ; Exit if negative

        jmp .loop

    .exit:
        mov rax, 60             ; syscall: exit
        xor rdi, rdi            ; status: 0
        syscall
