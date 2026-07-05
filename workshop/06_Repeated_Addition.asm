; Multiply by repeated addition

; Constants
section .data
    result db '00', 0xA     ; Two digits + newline

; Code
section .text
    global _start

_start:
    mov rdi, 5      ; First Number
    mov rsi, 4      ; Second Number
    call multiply   ; Call the multiply function
    ; Result in rax

    ; Convert to ASCII (works for 0-99)
    xor rdx, rdx    ; Zero out rdx
    mov rbx, 10
    div rbx         ; rax = rax / 10, rdx = remainder

    add rax, '0'    ; Convert number to ASCII digit
    add rdx, '0'    ; Convert number to ASCII digit
    mov [result], al
    mov [result + 1], dl

    ; Print
    mov rax, 1      ; syscall: write
    mov rdi, 1      ; stdout
    mov rsi, result ; buffer
    mov rdx, 3      ; 3 bytes (2 digit + newline)
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; multiply: rdi * rsi
; Returns rax = result
multiply:
    xor rax, rax    ; rax = 0 (accumulator)
    test rsi, rsi   ; Check if rsi = 0
    jz .done        ; If zero, we're done

.loop:
    add rax, rdi    ; Add first number
    dec rsi         ; Decrement counter
    jnz .loop       ; If not zero, continue jumping to .loop

.done:
    ret             ; Return rax

; `div` divides `rdx:rax` by operand (result in `rax`, remainder in `rdx`)
; `test` is like `cmp` but does bitwise AND (checks if zero)
; `.loop` and `.done` are local labels (scoped to nearest global label)
; `jz` (jump if zero), `jnz` (jump if not zero)
