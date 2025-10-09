; Arrays and Array Operations

; ------
; MACROS
; ------

; Macro: print - Prints a buffer
; Usage: print buffer, length
%macro print 2
    mov rax, 1      ; syscall: write
    mov rdi, 1      ; file-descriptor: stdout
    mov rsi, %1     ; buffer to print
    mov rdx, %2     ; length of bytes to print
    syscall
%endmacro

; Macro: print_msg - Print a predefined message
; Usage: print_msg my_message
%macro print_msg 1
    print %1, %1_len
%endmacro

; Macro: exit - Exit program with code
; Usage: exit 0
%macro exit 1
    mov rax, 60     ; syscall: exit
    mov rdi, %1     ; exit status code value
    syscall
%endmacro

; Macro: save_regs = Save registers to stack
%macro save_regs 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

; Macro: restore_regs - Restore registers from stack
%macro restore_regs 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro


; Data
section .data
    ; Test arrays
    array1 dq 5, 10, 15, 20, 25, 30
    array1_len equ 6

    array2 dq 42, 7, 99, 3, 67, 21, 88
    array2_len equ 7

    array3 dq 1, 2, 3, 4, 5
    array3_len equ 5

    ; Messages
    sum db 'Sum: ', 0
    sum_len equ $ - sum

    max db 'Max: ', 0
    max_len equ $ - max
    
    min db 'Min: ', 0
    min_len equ $ - min
    
    avg db 'Average: ', 0
    avg_len equ $ - avg
    
    original db 'Original: ', 0
    original_len equ $ - original
    
    reversed db 'Reversed: ', 0
    reversed_len equ $ - reversed
    
    sorted db 'Sorted: ', 0
    sorted_len equ $ - sorted
    
    search db 'Found at index: ', 0
    search_len equ $ - search
    
    not_found db 'Not Found!', 0
    not_found_len equ $ - not_found
    
    space db ' ', 0
    newline db 0xA
    
    separator db '---', 0xA
    separator_len equ $ - separator
    
; Uninitialized Data
section .bss
    temp_array resq 10          ; Temporary array for operations
    print_buffer resb 20        ; Buffer for number printing

; Code
section .text
    global _start

_start:
    ; Array Sum
    print_msg sum
    mov rdi, array1
    mov rsi, array1_len
    call array_sum
    call print_number
    call print_newline

    ; Array Max
    print_msg max
    mov rdi, array2
    mov rsi, array2_len
    call array_max
    call print_number
    call print_newline

    ; Array Min
    print_msg min
    mov rdi, array2
    mov rsi, array2_len
    call array_min
    call print_number
    call print_newline

    ; Array Average
    print_msg avg
    mov rdi, array1
    mov rsi, array1_len
    call array_average
    call print_number
    call print_newline

    ; Print Original Array
    print_msg original
    mov rdi, array3
    mov rsi, array3_len
    call print_array
    call print_newline

    ; Reverse Array
        ; First copy to temp array
        mov rdi, temp_array
        mov rsi, array3
        mov rdx, array3_len
        call array_copy

        ; Reverse it
        mov rdi, temp_array
        mov rsi, array3_len
        call array_reverse

        ; Show it
        print_msg reversed
        mov rdi, temp_array
        mov rsi, array3_len
        call print_array
        call print_newline

    print_msg separator

    ; Sort Array
        ; Copy to temp array
        mov rdi, temp_array
        mov rsi, array2
        mov rdx, array2_len
        call array_copy

        print_msg original
        mov rdi, temp_array
        mov rsi, array2_len
        call print_array
        call print_newline

        ; Sort it
        mov rdi, temp_array
        mov rsi, array2_len
        call array_sort

        print_msg sorted
        mov rdi, temp_array
        mov rsi, array2_len
        call print_array
        call print_newline

    print_msg separator

    ; Search for value
    print_msg search
    mov rdi, array2
    mov rsi, array2_len
    mov rdx, 99         ; Search for 99
    call array_search

    cmp rax, -1
    je .not_found
    call print_number
    call print_newline
    jmp .exit

.not_found:
    print_msg not_found

.exit:
    exit 0

; ---------------
; ARRAY FUNCTIONS
; ---------------

; Function: array_sum
; Input: RDI = array pointer, RSI = length
; Output: RAX = Sum of all elements
; Destroys: RCX
array_sum:
    xor rax, rax        ; Sum = 0
    xor rcx, rcx        ; Index = 0
    .loop:
        cmp rcx, rsi
        je .done
        add rax, [rdi + rcx*8]  ; Add array[i]
        inc rcx
        jmp .loop
    .done:
        ret

; Function: array_max
; Input: RDI = array pointer, RSI = length
; Output: RAX = Maximum Value
; Destroys RCX, RBX
array_max:
    test rsi, rsi       ; Check if array is empty
    jz .error

    mov rax, [rdi]      ; max = array[0]
    mov rcx, 1          ; Start from index 1

    .loop:
        cmp rcx, rsi
        je .done
        mov rbx, [rdi + rcx*8]
        cmp rbx, rax
        jle .skip
        mov rax, rbx    ; Update max
    .skip:
        inc rcx
        jmp .loop
    .done:
        ret
    .error:
        xor rax, rax
        ret

; Function: array_min
; Input RDI = array pointer, RSI = length
; Output: RAX = minimum value
; Destroys: RCX, RBX
array_min:
    test rsi, rsi
    jz .error

    mov rax, [rdi]      ; min = array[0]
    mov rcx, 1

    .loop:
        cmp rcx, rsi
        je .done
        mov rbx, [rdi + rcx*8]
        cmp rbx, rax
        jge .skip
        mov rax, rbx    ; Update min
    .skip:
        inc rcx
        jmp .loop
    .done:
        ret
    .error:
        xor rax, rax
        ret

; Function array_average
; Input RDI = array pointer, RSI = length
; Output RAX = average (integer division)
array_average:
    test rsi, rsi
    jz .error
    push rsi        ; Save length
    call array_sum  ; Get sum in Rax
    pop rsi         ; Restore length

    xor rdx, rdx    ; Clear rdx for division
    div rsi         ; Rax = Rax / Rsi
    ret
    .error:
        xor rax, rax
        ret

; Function array_reverse
; Input: RDI = array pointer, RSI = length
; Modifies array in place
; Destroys: RCX, RDX, RAX, RBX
array_reverse:
    xor rcx, rcx        ; left = 0
    mov rdx, rsi
    dec rdx             ; right = length - 1
    .loop:
        cmp rcx, rdx
        jge .done

        ; Swap array[left] and array[right]
        mov rax, [rdi + rcx*8]
        mov rbx, [rdi + rdx*8]
        mov [rdi + rdx*8], rax
        mov [rdi + rcx*8], rbx

        inc rcx
        dec rdx
        jmp .loop
    .done:
        ret


; Function: array_copy
; Input: RDI = destination, RSI = source, RDX = length
; Destroys: RCX, RAX
array_copy:
    xor rcx, rcx
    .loop:
        cmp rcx, rdx
        je .done
        mov rax, [rsi + rcx*8]
        mov [rdi + rcx*8], rax
        inc rcx
        jmp .loop
    .done:
        ret

; Function: array_search
; Input: RDI = array pointer, RSI = length, RDX = value to find
; Output: RAX = index (or -1 if not found)
array_search:
    xor rcx, rcx
    .loop:
        cmp rcx, rsi
        je .not_found
        cmp rdx, [rdi + rcx*8]
        je .found
        inc rcx
        jmp .loop
    .found: 
        mov rax, rcx
        ret
    .not_found:
        mov rax, -1
        ret

; Function: array_sort
; Input: RDI = array pointer, RSI = length
; Modifies array in place
; Destroys: R8, R9, R10, R11, RAX, RBX
array_sort:
    cmp rsi, 1
    jle .done       ; Already sorted if 0 or 1 elements

    mov r8, rsi     ; Outer loop counter
    dec r8          ; n - 1 passes

    .outer_loop:
        test r8, r8
        jz .done

        xor r9, r9  ; Inner Loop Counter
        mov r10, rsi
        dec r10     ; Compare up to n-1

        .inner_loop:
            cmp r9, r10
            jge .outer_continue

            ; Compare array[i] and array[i+1]
            mov rax, [rdi + r9*8]
            mov r11, r9
            inc r11
            mov rbx, [rdi + r11*8]

            cmp rax, rbx
            jle .no_swap

            ; Swap
            mov [rdi + r9*8], rbx
            mov [rdi + r11*8], rax
        
        .no_swap:
            inc r9
            jmp .inner_loop

    .outer_continue:
        dec r8
        jmp .outer_loop

    .done:
        ret

; UTILITY FUNCTIONS

; Function: print_array
; Input: RDI = array pointer, RSI = length
; Destroys: Many registers
print_array:
    push r12
    push r13

    mov r12, rdi        ; Save array pointer
    mov r13, rsi        ; Save length
    xor r14, r14        ; Index = 0

    .loop:
        cmp r14, r13
        je .done

        mov rax, [r12 + r14*8]
        push r12
        push r13
        push r14
        call print_number
        pop r14
        pop r13
        pop r12

        ; Print space (except after last element)
        mov rax, r14
        inc rax
        cmp rax, r13
        je .no_space

        print space, 1

        .no_space:
            inc r14
            jmp .loop

    .done:
        pop r13
        pop r12
        ret

; Function print_number
; Input: RAX = number to print
; Destroys: RAX, RBX, RCX, RDX
print_number:
    mov rbx, 10
    xor rcx, rcx
    
    ; Handle zero
    test rax, rax
    jnz .convert
    mov byte [print_buffer], '0'
    mov rcx, 1
    jmp .print

    .convert:
        xor rdx, rdx
        div rbx             ; RAX = RAX / 10, RDX = remainder
        add rdx, '0'
        push rdx
        inc rcx
        test rax, rax
        jnz .convert

        ; Pop digits into buffer
        xor rbx, rbx
    
    .pop:
        pop rax
        mov [print_buffer + rbx], al
        inc rbx
        dec rcx
        jnz .pop

    .print:
        push rbx        ; Save length
        print print_buffer, rbx
        pop rbx
        ret

; Function: print_newline
; Destroys RAX RDI, RSI, RDX
print_newline:
    print newline, 1
    ret
