; Echo

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

section .data
    space db ' ', 0
    newline db 0xA

section .text
    global _start

_start:
    ; Get argc
    mov r12, [rsp]          ; argc in r12

    ; Check if we have arguments
    cmp r12, 1
    jle .exit               ; No arguments, exit

    ; Start from argv[1] (skip program name)
    mov r13, 1              ; Current argument index

    .loop:
        cmp r13, r12
        jge .done

        ; Get pointer to current argument
        ; argv[i] is at [rsp + 8 + i * 8] (since we skipped (first) program name)
        mov rax, r13
        shl rax, 3              ; Multiply by 8 (2^3)
        add rax, 8              ; Add offset for argc
        mov rdi, [rsp + rax]    ; Get argv[i] pointer

        ; Print the argument
        call print_string

        ; Print space (except after last argument)
        mov rax, r13
        inc rax
        cmp rax, r12
        jge .no_space
        mov rax, 1              ; Syscall write
        mov rdi, 1              ; FD: Stdout
        mov rsi, space          ; buffer to write
        mov rdx, 1              ; bytes to write
        syscall

        .no_space:
            inc r13
            jmp .loop

        .done:
            ; Print newline at the end
            mov rax, 1          ; Syscall write
            mov rdi, 1          ; File Descriptor: Stdout
            mov rsi, newline    ; buffer to write
            mov rdx, 1          ; bytes to write
            syscall

        .exit:
            mov rax, 60         ; Syscall exit
            xor rdi, rdi        ; Zero out rdi for status code 0
            syscall

; Function: print_string
; Input: RDI = string pointer
print_string:
    push rdi    ; Save String Pointer

    ; Calculate length
    xor rax, rax    ; Zero out rax, start at 0
    .len_loop:
        cmp byte [rdi], 0
        je  .print
        inc rax
        inc rdi
        jmp .len_loop

    .print:
        mov rdx, rax        ; length
        pop rsi             ; String pointer
        mov rax, 1          ; Syscall write
        mov rdi, 1          ; fd stdout
        syscall
        ret

