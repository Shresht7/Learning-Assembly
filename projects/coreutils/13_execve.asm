; The `execve` syscall is the foundation of every shell.
; It replaces the current process with a new one, effectively running a new program.
; If `execve` is successful, the new program takes over and the original code stops existing in memory

; Syscall: 59 (0x3b)
; RDI: Path to the executable (null-terminated string)
; RSI: Argument Vector (array of pointers to null-terminated strings, terminated by a NULL pointer)
; RDX: Environment Variables (array of pointers to null-terminated strings, terminated by a NULL pointer)

section .data
    path db '/bin/ls', 0    ; The program to run
    arg1 db '-l', 0         ; Argument for ls

    ; The argument vector (argv): [path_ptr, arg1_ptr, 0]
    argv dq path
         dq arg1
         dq 0                ; Null pointer to terminate argv

section .text
    global _start

_start:
    mov rax, 59          ; syscall number for execve
    mov rdi, path        ; pointer to the program path
    mov rsi, argv        ; pointer to the argument vector
    xor rdx, rdx         ; envp is NULL (no environment variables)
    syscall               ; invoke the syscall

    ; If we reach this point, it means execve has failed.
    mov rax, 60          ; syscall number for exit
    mov rdi, 1           ; exit code 1 for failure
    syscall              ; exit the process
