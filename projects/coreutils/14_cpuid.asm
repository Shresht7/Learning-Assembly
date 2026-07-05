; The cpuid instruction is used to get information about the CPU, such as its features and capabilities.

section .data
    newline db 0xA

section .bss
    vendor_id resb 13   ; 12 bytes for vendor ID + null terminator

section .text
    global _start

_start:
    ; Call CPUID with eax = 0
    xor rax, rax        ; Set rax to 0 for CPUID
    cpuid

    ; Move the results into our buffer
    ; The string is returned in ebx, edx, and ecx
    mov [vendor_id], ebx
    mov [vendor_id + 4], edx
    mov [vendor_id + 8], ecx
    mov byte [vendor_id + 12], 0 ; Null-terminate the string

    ; Print the vendor ID
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    lea rsi, [vendor_id]    ; pointer to the vendor ID string
    mov rdx, 12             ; length of the vendor ID string
    syscall

    ; Print a newline
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    lea rsi, [newline]     ; pointer to the newline character
    mov rdx, 1              ; length of the newline character
    syscall

    ; Exit the program
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; exit code 0
    syscall
