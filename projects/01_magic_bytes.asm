; Magic Bytes: Read and display the magic bytes of any file
;
; Usage: ./magic_bytes <filename>
;
; Displays the first 8 bytes of a file in hexadecimal format.
; Magic bytes (also called file signatures) are the first few bytes
; of a file that uniquely identify its format. For example:
;  7F 45 4C 46  = ELF (Executable and Linkable Format)
;  89 50 4E 47  = PNG image
;  FF D8 FF     = JPEG image
;  25 50 44 46  = PDF document
;  47 49 46 38  = GIF file

section .data
    usage_msg db 'Usage: magic_bytes <filename>', 0xA
    usage_msg_len equ $ - usage_msg

    error_open db 'Error: Could not open file', 0xA
    error_open_len equ $ - error_open

    error_read db 'Error: Could not read file', 0xA
    error_read_len equ $ - error_read

    empty_msg  db '(file is empty)', 0xA
    empty_msg_len equ $ - empty_msg

    hex_chars db '0123456789ABCDEF'

    separator db '  '
    newline db 0xA

section .bss
    buffer  resb 8      ; To store the first 8 bytes of the file
    hex_out resb 2      ; To store the hexadecimal representation of a single byte

section .text
    global _start

_start:
    ; Check if the correct number of arguments is provided
    mov rax, [rsp]
    cmp rax, 2
    jne .usage_error

    ; Open the file specified in the command line argument
    mov rax, 2              ; syscall: open
    mov rdi, [rsp + 16]     ; pointer to the filename (first argument)
    xor rsi, rsi            ; flags: O_RDONLY
    xor rdx, rdx            ; mode: not used for O_RDONLY
    syscall

    ; Check if the file was opened successfully
    test rax, rax
    js .open_error

    mov r12, rax    ; Store the file descriptor in r12 for later use

    ; Read the first 8 bytes of the file
    mov rax, 0              ; syscall: read
    mov rdi, r12            ; file descriptor
    mov rsi, buffer         ; buffer to store the bytes
    mov rdx, 8              ; number of bytes to read
    syscall

    ; Check if the read was successful
    test rax, rax
    js .read_error
    jz .empty

    mov r13, rax    ; Store the number of bytes read in r13 for later use

    ; Print the magic bytes in hexadecimal format
    mov rax, 3      ; syscall: write
    mov rdi, r12    ; file descriptor
    ; rsi points to the buffer containing the bytes
    ; rdx contains the number of bytes read (up to 8)
    syscall

    xor rcx, rcx    ; Initialize counter for the loop

.print_loop:
    ; Check if we have printed all the bytes read
    cmp rcx, r13
    jge .newline    ; If all bytes are printed, print a newline and exit

    ; Load the byte from the buffer
    movzx rdx, byte [buffer + rcx]

    ; Convert the byte to hexadecimal representation
    mov rbx, rdx                ; Copy the byte to rbx for manipulation
    shr rbx, 4                  ; Get the high nibble (4 bits)
    mov al, [hex_chars + rbx]   ; Get the corresponding hex character for the high nibble
    mov [hex_out], al           ; Store the high nibble character in hex_out

    and rdx, 0xF                ; Get the low nibble (4 bits)
    mov al, [hex_chars + rdx]   ; Get the corresponding hex character for the low nibble
    mov [hex_out + 1], al       ; Store the low nibble character in hex_out

    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    mov rsi, hex_out            ; Pointer to the hex_out buffer
    mov rdx, 2                  ; Number of bytes to write (2 hex characters)
    syscall

    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    mov rsi, separator          ; Pointer to the separator buffer
    mov rdx, 2                  ; Number of bytes to write (2 characters)
    syscall

    ; Increment the counter and loop to print the next byte
    inc rcx
    jmp .print_loop

.newline:
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    mov rsi, newline            ; Pointer to the newline buffer
    mov rdx, 1                  ; Number of bytes to write (1 character)
    syscall

    ; Exit the program successfully
    mov rax, 60
    xor rdi, rdi
    syscall

.usage_error:
    mov rax, 1                  ; syscall: write
    mov rdi, 2                  ; file descriptor: stderr
    mov rsi, usage_msg          ; Pointer to the usage message buffer
    mov rdx, usage_msg_len      ; Length of the usage message
    syscall

    mov rax, 60                 ; syscall: exit
    mov rdi, 1                  ; Exit code: 1
    syscall

.open_error:
    mov rax, 1                  ; syscall: write
    mov rdi, 2                  ; file descriptor: stderr
    mov rsi, error_open         ; Pointer to the error message buffer
    mov rdx, error_open_len     ; Length of the error message
    syscall

    mov rax, 60                 ; syscall: exit
    mov rdi, 1                  ; Exit code: 1
    syscall

.read_error:
    mov rax, 1                  ; syscall: write
    mov rdi, 2                  ; file descriptor: stderr
    mov rsi, error_read         ; Pointer to the error message buffer
    mov rdx, error_read_len     ; Length of the error message
    syscall

    mov rax, 60                 ; syscall: exit
    mov rdi, 1                  ; Exit code: 1
    syscall

.empty:
    mov rax, 1                  ; syscall: write
    mov rdi, 1                  ; file descriptor: stdout
    mov rsi, empty_msg          ; Pointer to the empty message buffer
    mov rdx, empty_msg_len      ; Length of the empty message
    syscall

    mov rax, 60                 ; syscall: exit
    xor rdi, rdi                ; Exit code: 0
    syscall
