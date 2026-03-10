; Every linux executable starts with a 16-byte header called the ELF header.
; The first 4 bytes are the magic number, which should be 0x7F followed by 'E', 'L', 'F'.
; This is how the kernel knows that it's looking at a binary that it can execute

section .data
    filename db '/bin/ls', 0    ; The program to check

    is_elf db 'File is a valid ELF binary!', 0xA
    is_elf_len equ $ - is_elf

    is_not_elf db 'File is NOT a valid ELF binary', 0xA
    is_not_elf_len equ $ - is_not_elf

section .bss
    header resb 4   ; Reserve 4 bytes for the ELF magic number

section .text
    global _start

_start:
    ; Open the file
    mov rax, 2          ; syscall: open
    mov rdi, filename   ; pointer to the filename
    xor rsi, rsi       ; flags = O_RDONLY (0)
    syscall

    ; Save file-descriptor to R8 (RAX contains the file-descriptor)
    mov r8, rax

    ; Read the first 4 bytes
    mov rax, 0          ; syscall: read
    mov rdi, r8         ; file descriptor
    mov rsi, header     ; buffer to store the header
    mov rdx, 4          ; number of bytes to read
    syscall

    ; Check for 0x7F 'E' 'L' 'F'
    ; The ELF magic number is 0x7F followed by 'E', 'L', 'F' (0x45, 0x4C, 0x46)
    ; Note: x86-64 is little-endian, so the bytes will be in reverse order in the register
    cmp dword [header], 0x464C457F ; Compare with 'F', 'L', 'E', 0x7F
    je .valid

    ; If we get here, it's not a valid ELF file
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    lea rsi, [is_not_elf]       ; pointer to the "not ELF" message
    mov rdx, is_not_elf_len     ; length of the message
    syscall

    ; Exit the program
    jmp .exit

.valid:
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    lea rsi, [is_elf]           ; pointer to the "is ELF" message
    mov rdx, is_elf_len         ; length of the message
    syscall

    ; Exit the program
    jmp .exit

.exit:
    ; Close the file
    mov rax, 3          ; syscall: close
    mov rdi, r8         ; file descriptor
    syscall

    ; Exit the program
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; exit code 0
    syscall
