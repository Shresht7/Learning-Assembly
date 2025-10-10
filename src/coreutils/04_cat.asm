; cat - concatenate files and print on the standard output
; usage: cat [file]...

section .bss
    buffer resb 8192        ; Reserve 8KB for buffer

section .text
    global _start

_start:
    pop r12                 ; r12 = argc
    pop rsi                 ; skip argv[0]
    dec r12                 ; argc - 1

    ; Check argc count
    test r12, r12
    jz .read_stdin          ; If no args, read from stdin

    .file_loop:
        pop rdi             ; rdi = filename

        ; open(filename, O_RDONLY)
        mov rax, 2          ; syscall: open
        xor rsi, rsi        ; flags: O_RDONLY (0)
        xor rdx, rdx        ; mode: 0
        syscall

        ; Check if we had any error opening this file
        test rax, rax
        js .next_file       ; if open failed, skip this file

        mov r13, rax        ; Store the opened file descriptor in r13
        call .cat_fd

        ; close(fd)
        mov rax, 3          ; syscall: close
        mov rdi, R13        ; file descriptor of opened file
        syscall

        .next_file:
            dec r12
            test r12, r12
            jnz .file_loop
            jmp .exit

    .read_stdin:
        xor r13, r13        ; fd = 0 (stdin)
        call .cat_fd
        jmp .exit

; Read from fd in r13 and write to stdout
.cat_fd:
.read_loop:
    ; read(fd, buffer, 8192)
    mov rax, 0              ; syscall: read
    mov rdi, r13            ; file descriptor
    mov rsi, buffer         ; The buffer to store the read content
    mov rdx, 8192           ; The number of bytes to store
    syscall

    ; Check for errors
    test rax, rax
    jle .read_done          ; If EOF or error, done

    mov r14, rax            ; r14 = bytes read

    ; write(stdout, buffer, bytes_read)
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, buffer         ; the buffer to write to stdout
    mov rdx, r14            ; The number of bytes to write
    syscall

    jmp .read_loop

.read_done:
    ret

.exit:
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; exit status code 0
    syscall
