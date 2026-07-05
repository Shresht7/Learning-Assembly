; Count from 1 to 10

; Constants
section .data
    digit db '0', 0xA

; Code
section .text
    global _start

_start:
    mov r12, 1          ; Counter starts at 1

loop_start:
    ; Check if we're done
    cmp r12, 11         ; If r12 has reached 11, then we're done, exit loop
    je loop_end

    ; Convert counter to ASCII
    mov rax, r12
    add rax, '0'        ; Add ASCII '0' to number to get ASCII digit
    mov [digit], al

    ; Save counter before syscall
    push r12            ; Save R12 on stack

    ; Print digit
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: 1 for stdout
    mov rsi, digit      ; buffer: contents to print
    mov rdx, 2          ; length of buffer. 2 bytes
    syscall             ; Call the system to write to stdout

    ; Restore counter after syscall
    pop r12             ; Restore R12 from stack

    ; Increment Counter
    inc r12             ; r12 = r12 + 1

    ; Jump to loop start
    jmp loop_start      ; Repeat until we jump to loop_end when r12 -> 11

loop_end:
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; Status Code 0 for Success.
    syscall             ; Ask the kernel to exit

; `inc`: Increments by 1 (also `dec` decrements by 1)
; Loop pattern: Check condition -> do work -> increment -> repeat. (aka While loop)
; `rcx` traditionally used for counters (but any register works)
; Had to change `rcx` to `r12` as the `syscall` can modify `rcx`.
