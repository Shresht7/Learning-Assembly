; filesize.asm

section .data
    usage_msg db "Usage: filesize <path>", 10
    usage_len equ $ - usage_msg

    err_msg db "Error", 10
    err_len equ $ - err_msg

    dir_msg db ": is a directory", 10
    dir_len equ $ - dir_msg

section .bss
    buf_digits resb 32          ; buffer for integer -> string (enough for 64-bit decimal + newline)

    statbuf resb 144            ; buffer for struct stat

section .text
    global _start

_start:
    ; argc at [rsp], argv at [rsp+8]
    ; On process entry, rsp -> argc
    mov rax, [rsp]              ; rax = argc
    cmp rax, 2                  ; Check if argument count it atleast 2
    jl .usage                   ; need at least argv[1]

    ; load argv[1] pointer: argv is at [rsp + 8], so argv[1] at [rsp + 8 + 8]
    mov rbx, [rsp + 8 + 8]      ; rbx = argv[1] pointer

    ; Syscall: open(filename, O_RDONLY)
    mov rax, 2                  ; SYS_open
    mov rdi, rbx                ; char *filename
    xor rsi, rsi                ; flags = O_RDONLY (0)
    xor rdx, rdx                ; mode = 0
    syscall

    ; rax = fd or negative error
    test rax, rax
    js .sys_error
    mov r12, rax                ; save file descriptor in r12

    ; fstat(fd, &statbuf)
    mov rax, 5                  ; SYS_fstat
    mov rdi, r12
    lea rsi, [rel statbuf]
    syscall

    test rax, rax
    js .close_and_error

    ; check st_mode at offset 24 (on x86_64) Linux
    mov rax, [statbuf + 24]
    and ax, 0xF000
    cmp ax, 0x4000              ; S_IFDIR?
    je .is_directory

    ; lseek(fd, 0, SEEK_END)
    mov rax, 8                  ; SYS_lseek
    mov rdi, r12                ; file descriptor
    xor rsi, rsi                ; offset = 0
    mov rdx, 2                  ; whence = SEEK_END (2)
    syscall

    ;rax = resulting offset (file size) or negative error
    test rax, rax
    js .close_and_error
    mov rbx, rax                ; rbx = file size (low 64 bit). fits in 64-bit

    ; close(fd)
    mov rax, 3                  ; SYS_close
    mov rdi, r12
    syscall
    ; (ignore close errors)

    ; Convert rbx (unsigned) to decimal string in buf_digits
    mov rsi, buf_digits
    add rsi, 31                 ; point rsi to end of buffer
    mov byte [rsi], 10          ; newline
    dec rsi                     ; place digits before newline

    xor rcx, rcx                ; digit count

    ; handle zero specially
    cmp rbx, 0
    jne .convert_loop
    mov byte [rsi], '0'
    dec rsi
    inc rcx
    jmp .print_digits

.convert_loop:
    ; We'll divide rbx by 10 repeatedly
    ; Use rax:rdx for div; move dividend to rax, clear rdx
    ; We'll use rcx as digit counter
.convert_repeat:
    mov rax, rbx
    xor rdx, rdx
    mov rdi, 10
    ; use div: rax / rdi -> quotient in rax, remainder in rdx
    ; but div uses implicit operand / requires divisor in register. We'll use 'div rdi' where rdi=10
    div rdi                     ; quotient -> rax, remainder -> rdx
    ; remainder in rdx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    inc rcx
    mov rbx,rax                 ; update rbx = quotient
    cmp rbx, 0
    jne .convert_repeat

.print_digits:
    ; rsi currently points one byte before first digit (we backed up after last write),
    ; so the first digit starts at rsi + 1. Total length is rcx + 1 (newline).
    lea rdx, [rcx + 1]          ; length = number of digits + newline
    lea rsi, [rsi + 1]          ; start of digits
    mov rdi, 1                  ; stdout
    mov rax, 1                  ; SYS_write
    syscall

    ; exit 0
    mov rax, 60
    xor rdi, rdi
    syscall

.is_directory:
    ; print "<path>: is a directory"
    mov rax, 1
    mov rdi, 1
    mov rsi, [rsp + 8 + 8]
    mov rdx, 0
.print_path:
    mov al, [rsi + rdx]
    cmp al, 0
    je .after_path
    inc rdx
    jmp .print_path
.after_path:
    mov rax, 1
    mov rdi, 1
    mov rsi, [rsp + 8 + 8]
    syscall                     ; Prints filename

    ; Print directory message
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel dir_msg]
    mov rdx, dir_len
    syscall

    ; close fd
    mov rax, 3
    mov rdi, r12
    syscall

    ; exit 0
    mov rax, 60
    mov rdi, 2
    syscall

.usage:
    mov rax, 1                  ; SYS_write
    mov rdi, 1
    lea rsi, [rel usage_msg]
    mov rdx, usage_len
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

.sys_error:
    ; write generic error message and exit 1
    mov rax, 1
    mov rdi, 2                  ; stderr
    lea rsi, [rel err_msg]
    mov rdx, err_len
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

.close_and_error:
    ; attempt to close fd in r12, then error
    mov rax, 3
    mov rdi, r12
    syscall
    jmp .sys_error
