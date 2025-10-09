; Implement Common String Operations

; Constants
section .data
    test_str db 'Wow!', 0
    length_msg db 'Length: ', 0
    length_msg_len equ $ - length_msg

    source db 'Copy Me!', 0
    source_len equ $ - source

    str1 db 'Apple', 0
    str2 db 'Apple', 0
    str3 db 'Banana', 0

    msg_equal db 'Strings are equal', 0xA
    msg_equal_len equ $ - msg_equal

    msg_not_equal db 'Strings are different', 0xA
    msg_not_equal_len equ $ - msg_not_equal

    str4 db 'Hello ', 0
    str5 db 'World!', 0

    newline db 0xA

; Uninitialized Data
section .bss
    digit resb 1    ; Reserve 1 byte for the digit
    copy_dest resb 50       ; Reserve 50 bytes for a place to copy to
    concat resb 100         ; Reserve 100 bytes for a place to store the concatenated string

; Code
section .text
    global _start

_start:
    call _calculate_length
    call _copy_string
    call _compare_strings
    call _concatenate_strings
    call _exit

_calculate_length:
    ; Calculate String Length
    mov rdi, test_str
    call strlen
    ; Result in RAX

    ; Print Result Message
    push rax                    ; Save length in stack
    mov rax, 1                  ; Prepare for syscall: write
    mov rdi, 1                  ; fd: stdout
    mov rsi, length_msg         ; Message to write
    mov rdx, length_msg_len     ; Length of bytes to write
    syscall
    pop rax                     ; Restore length from stack

    ; Print Length (assuming < 10)
    add rax, '0'
    mov [digit], al
    mov rax, 1
    mov rdi, 1
    mov rsi, digit
    mov rdx, 1
    syscall

    call _print_new_line
    ret

_copy_string:
    mov rdi, copy_dest
    mov rsi, source
    call strcpy

    ; Print Destination
    mov rdi, copy_dest
    call strlen
    mov rdx, rax        ; Use Actual length

    mov rax, 1
    mov rdi, 1
    mov rsi, copy_dest
    syscall

    call _print_new_line
    ret

_compare_strings:
    ; Compare str1 and str2
    mov rdi, str1
    mov rsi, str2
    call strcmp ; Returns RAX

    test rax, rax   ; Check result
    jnz .not_equal

    ; They're equal
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_equal
    mov rdx, msg_equal_len
    syscall
    ret

    .not_equal:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_not_equal
        mov rdx, msg_not_equal_len
        syscall
        ret

_concatenate_strings:
    ; Copy str4 to concat
    mov rdi, concat
    mov rsi, str4
    call strcpy

    ; Find end of result
    mov rdi, concat
    call strlen             ; Result in RAX
    add rdi, rax            ; Move to end of string

    ; Append str5
    mov rsi, str5
    call strcpy

    ; Print Result
    mov rdi, concat
    call strlen             ; Result in rax

    mov r12, rax            ; Save Length in a Safe Register
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; stdout
    mov rsi, concat         ; buffer
    mov rdx, r12            ; Use saved length
    syscall

    call _print_new_line
    ret

_print_new_line:
    ; Print Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
    
_exit:
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; Function: strlen
; Input: RDI = pointer to null-terminated string
; Output: RAX = length
; Preserves: RDI (IMPROVED!)
strlen:
    push rdi                    ; Save RDI to preserve it
    xor rax, rax                ; Counter = 0
    .loop:
        cmp byte [rdi], 0       ; Check for null terminator
        je .done                ; If match, jump to .done
        inc rax                 ; Increment counter
        inc rdi                 ; Move to next character
        jmp .loop               ; Repeat Loop
    .done:
        pop rdi                 ; Restore RDI
        ret

; Function: strcpy
; Input: RDI = Destination, RSI = Source
; Output: None
; Destroys: RAX, RDI, RSI
strcpy:
    .loop:
        mov al, [rsi]           ; Load byte from source
        mov [rdi], al           ; Store to Destination
        test al, al             ; Check if it was null
        jz .done                ; Jump to .done if it was
        inc rsi                 ; Next source byte
        inc rdi                 ; Next destination byte
        jmp .loop               ; Repeat the loop
    .done:
        ret

; Function: strcmp
; Input: RDI = string 1, RSI = string 2
; Output: RAX = 0 if equal, non-zero otherwise
; Destroys: RDI, RSI, RBX, RCX
strcmp:
    .loop:
        mov bl, [rdi]           ; Load byte from str1
        mov cl, [rsi]           ; Load byte from str2
        cmp bl, cl              ; Compare them
        jne .not_equal

        test bl, bl             ; Check if we hit null-terminator
        jz .equal               ; if yes, strings are equal

        inc rdi                 ; Next character in str1
        inc rsi                 ; Next character in str2
        jmp .loop               ; Repeat loop

    .equal:
        xor rax, rax            ; Return 0
        ret

    .not_equal:
        mov rax, 1              ; Return non-zero
        ret
