; Complete File I/o Operations

; ------
; MACROS
; ------

%macro print 2
    mov rax, 1     ; syscall: write
    mov rdi, 1     ; fd: stdout
    mov rsi, %1    ; buffer to print
    mov rdx, %2    ; length of bytes to print
    syscall        ; Ask the kernel to print
%endmacro

%macro print_msg 1
    print %1, %1_len
%endmacro

%macro exit 1
    mov rax, 60     ; syscall: exit
    mov rdi, %1     ; mov rdi, %1
    syscall
%endmacro

; ---------
; CONSTANTS
; ---------

; File open flags (combine with OR)
; Read Only
%define O_RDONLY    0
; Write Only
%define O_WRONLY    1
; Read and Write
%define O_RDWR      2
; Create if doesn't exist (0x40)
%define O_CREAT     64
; Truncate to 0 length (0x200)
%define O_TRUNC     512
; Append Mode (0x400)
%define O_APPEND    1024

; File Permissions (Octal)
; rw-r--r--
%define PERMS_644   0644o
; rwxr-xr-x
%define PERMS_755   0755o

; Syscall numbers
%define SYS_READ    0
%define SYS_WRITE   1
%define SYS_OPEN    2
%define SYS_CLOSE   3

; ------------
; DATA SECTION
; ------------

section .data
    ; File Names
    write_file db 'test_output.txt', 0
    read_file db 'test_output.txt', 0
    append_file db 'append_test.txt', 0
    copy_src db 'source.txt', 0
    copy_dst db 'dest.txt', 0

    ; Content to write
    content1 db 'Hello from Assembly!', 0xA
    content1_len equ $ - content1
    
    content2 db 'This is line 2', 0xA
    content2_len equ $ - content2
    
    content3 db 'Appended line', 0xA
    content3_len equ $ - content3
    
    ; Messages
    write_success db 'File written successfully!', 0xA
    write_success_len equ $ - write_success
    
    read_success db 'File read successfully!', 0xA
    read_success_len equ $ - read_success

    append_success db 'Content appended!', 0xA
    append_success_len equ $ - append_success

    copy_success db 'File copied successfully!', 0xA
    copy_success_len equ $ - copy_success
            
    error_open db 'Error: Could not open file!', 0xA
    error_open_len equ $ - error_open
    
    error_read db 'Error: Could not read file!', 0xA
    error_read_len equ $ - error_read
    
    error_write db 'Error: Could not reald file!', 0xA
    error_write_len equ $ - error_write
    
    file_contents db 'File Contents: ', 0xA
    file_contents_len equ $ - file_contents
    
    separator db '===========================', 0xA
    separator_len equ $ - separator
    

    newline db 0xA

; Unitialized Data
section .bss
    buffer resb 4096            ; 4KB buffer for reading
    bytes_read resq 1           ; Store number of bytes read

; ------------
; CODE SECTION
; ------------

section .text
    global _start

_start:
    ; Write to File
    call write_file_fn
    print_msg separator

    ; Read from File
    call read_file_fn
    print_msg separator

    ; Append to File
    call append_file_fn
    print_msg separator

    ; Copy File
    call copy_file_fn
    print_msg separator

    ; Read and Display line-by-line
    call read_lines_fn

    ; Exit
    exit 0

; FUNCTIONS
; ---------

; Write to File
write_file_fn:
    ; Open file for writing (create if it doesn't exit, truncate if it exists)
    mov rax, SYS_OPEN
    mov rdi, write_file
    mov rsi, O_CREAT | O_WRONLY | O_TRUNC   ; 0x241 = 577
    mov rdx, PERMS_644
    syscall

    ; Check for error
    test rax, rax
    js .error

    mov r12, rax        ; Save file descriptor

    ; Write First Line
    mov rax, SYS_WRITE
    mov rdi, r12
    mov rsi, content1
    mov rdx, content1_len
    syscall

    test rax, rax
    js .error_write

    ; Write Second Line
    mov rax, SYS_WRITE
    mov rdi, r12
    mov rsi, content2
    mov rdx, content2_len
    syscall

    test rax, rax
    js .error_write

    ; Close File
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall

    print_msg write_success
    ret

    .error:
        print_msg error_open
        ret

    .error_write:
        print_msg error_write
        ; Close file before returning
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall
        ret

; Read from File
read_file_fn:
    ; Open file for reading
    mov rax, SYS_OPEN
    mov rdi, read_file
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    test rax, rax
    js .error

    mov r12, rax        ; Save file descriptor

    ; Read from File
    mov rax, SYS_READ
    mov rdi, r12
    mov rsi, buffer
    mov rdx, 4096
    syscall

    test rax, rax
    js .error_read

    mov [bytes_read], rax       ; Save bytes read

    ; Close file
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall

    ; Print Success Message
    print_msg read_success

    ; Print Contents
    print_msg file_contents
    print buffer, [bytes_read]

    ret

    .error:
        print_msg error_open
        ret

    .error_read:
        print_msg error_read
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall
        ret

; Append to File
append_file_fn:
    ; Open file for appending (create if it doesn't exist)
    mov rax, SYS_OPEN
    mov rdi, append_file
    mov rsi, O_CREAT | O_WRONLY | O_APPEND  ; 0x441 = 1089
    mov rdx, PERMS_644
    syscall

    test rax, rax
    js .error

    mov r12, rax

    ; Write Content
    mov rax, SYS_WRITE
    mov rdi, r12
    mov rsi, content3
    mov rdx, content3_len
    syscall

    test rax, rax
    js .error_write

    ; Close file
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall

    print_msg append_success
    ret

    .error:
        print_msg error_open
        ret

    .error_write:
        print_msg error_write
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall
        ret

; Copy File
copy_file_fn:
    ; First create a source file to copy
    call create_source_file

    ; Open Source File
    mov rax, SYS_OPEN
    mov rdi, copy_src
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    test rax, rax
    js .error_src

    mov r13, rax            ; Destination file descriptor

    .copy_loop:
        ; Read from source
        mov rax, SYS_READ
        mov rdi, r12
        mov rsi, buffer
        mov rdx, 4096
        syscall

        test rax, rax
        jz .done                ; EOF reached
        js .error_read_copy     


        mov r14, rax            ; Save bytes read

        ; Write to Destination
        mov rax, SYS_WRITE
        mov rdi, r13
        mov rsi, buffer
        mov rdx, r14
        syscall

        test rax, rax
        js .error_write_copy

        jmp .copy_loop

    .done:
        ; Close both files
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall

        mov rax, SYS_CLOSE
        mov rdi, r13
        syscall

        print_msg copy_success
        ret

    .error_src:
        print_msg error_open
        ret

    .error_dst:
        print_msg error_open
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall
        ret

    .error_read_copy:
        print_msg error_read
        jmp .cleanup

    .error_write_copy:
        print_msg error_write
        jmp .cleanup

    .cleanup:
        ; Close botth files
        mov rax, SYS_CLOSE
        mov rdi, r12
        syscall
        mov rax, SYS_CLOSE
        mov rdi, r13
        syscall
        ret


; Read File Line-by-Line
read_lines_fn:
    ; Open File
    mov rax, SYS_OPEN
    mov rdi, read_file
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    test rax, rax
    js .error

    mov r12, rax        ; Save file descriptor

    print_msg file_contents

    .read_loop:
        ; Read one byte at a time (inefficient but demonstrates the concept)
        mov rax, SYS_READ
        mov rdi, r12
        mov rsi, buffer
        mov rdx, 1
        syscall

        test rax, rax
        jz .eof             ; No more data
        js .error_read

        ; Print the character
        print buffer, 1

        jmp .read_loop

        .eof:
            ; Close File
            mov rax, SYS_CLOSE
            mov rdi, r12
            syscall
            ret

        .error:
            print_msg error_open
            ret

        .error_read:
            print_msg error_read
            mov rax, SYS_CLOSE
            mov rdi, r12
            syscall
            ret


; ----------------
; HELPER FUNCTIONS
; ----------------

; Create a source file for copying
create_source_file:
    mov rax, SYS_OPEN
    mov rdi, copy_src
    mov rsi, O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, PERMS_644
    syscall

    test rax, rax
    js .error

    mov r12, rax        ; Save file descriptor

    ; Write some content
    mov rax, SYS_WRITE
    mov rdi, r12
    mov rsi, content1
    mov rdx, content1_len
    syscall

    mov rax, SYS_WRITE
    mov rdi, r12
    mov rsi, content2
    mov rdx, content2_len
    syscall

    .error:
        ret

; ---------------------------
; REUSABLE FILE I/O FUNCTIONS
; ---------------------------

; Function: file_open_read
; Input: RDI = filename pointer
; Output: RAX = file descriptor (or -1 on error)
file_open_read:
    mov rax, SYS_OPEN
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    ret

; Function: file_open_write
; Input: RDI = filename pointer
; Output: RAX = file descriptor (or -1 on error)
file_open_write:
    mov rax, SYS_OPEN
    mov rsi, O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, PERMS_644
    syscall
    ret

; Function: file_open_append
; Input: RDI = filename pointer
; Output: RAX = file descriptor (or -1 on error)
file_open_append:
    mov rax, SYS_OPEN
    mov rsi, O_CREAT | O_WRONLY | O_APPEND
    mov rdx, PERMS_644
    syscall
    ret

; Function: file_read
; Input: RDI = fd, RSI = buffer, RDX = size
; Output: RAX = bytes read (or -1 on error)
file_read:
    mov rax, SYS_READ
    syscall
    ret

; Function: file_write
; Input: RDI = fd, RSI = buffer, RDX = size
; Output: RAX = bytes written (-1 on error)
file_write:
    mov rax, SYS_WRITE
    syscall
    ret

; Function: file_close
; Input: RDI = fd
; Output: RAX = 0 on success, -1 on error
file_close:
    mov rax, SYS_CLOSE
    syscall
    ret

; ## File Descriptor

; A File Descriptor (fd) is just a number that represents an open file:
; - 0 = stdin (standard input)
; - 1 = stdout (standard output)
; - 2 = stderr (standard error)
; - 3+ = your opened files

; ## File Open flags

; You can combine flags with OR (`|`):
; ```asm
; ; Read only
; O_RDONLY = 0
; 
; ; Write only, craete if doesn't exist, trunctate to zero
; O_WRONLY | O_CREAT | O_TRUNC = 1 | 64 | 512 = 577 (0x241)
;
; ; Write only, create if doesn't exist, append to end
; O_WRONLY | O_CREAT | O_APPEND = 1 | 64 | 1024 = 1089 (0x441)
; ```

; ## File Permissions (Linux)

; Octal Notation:

; 0644 = rw- r-- r--
;        ||| ||| |||
;        ||| ||| ____ Others: Read
;        |||_________ Group: Read
;        |||_________ Owner: Read + Write

; 0755 = rwx r-x r-x
;        ||| ||| |||
;        ||| ||| ____ Others: Read + Execute
;        ||| ________ Group: Read + Execute
;        ____________ Owner: Read + Write + Execute


; ## Error Checking
; System calls return `-1` on error. use `test` or `cmp`:
; ```
; syscall
; test rax, rax     ; Check if negative
; js .error         ; Jump if sign flag is set (negative)
;
; Or:
; cmp rax, 0
; jl .error         ; Jump if less than 0
; ```
