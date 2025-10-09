; Basic HTTP Web Server in Assembly
; Listens on port 8080 and serves simple responses

; -------------
; CONSTANT DATA
; -------------

section .data
    ; HTTP Response
    http_response db 'HTTP/1.1 200 OK', 0xD, 0xA
                  db 'Content-Type: text/html, charset=UTF-8', 0xD, 0xA         ; Not sure how to escape a ; before charset
                  db 'Connection: close', 0xD, 0xA
                  db 0xD, 0xA                                                   ; 0xD, 0xA is probably \r\n
                  db '<!DOCTYPE html>', 0xA
                  db '<html>', 0xA
                  db '<head><title>Assembly Web Server</title></head>', 0xA
                  db '<body>', 0xA
                  db '<h1>Hello from Assembly!</h1>', 0xA
                  db '<p>This page is served by a web server written in x86-64 assembly!</p>', 0xA
                  db '<p>Request recieved and processed successfully.</p>', 0xA
                  db '</body>', 0xA
                  db '</html>', 0xA
    http_response_len equ $ - http_response

    ; Server messages
    server_start db 'Server starting on http://localhost:8080', 0xA
    server_start_len equ $ - server_start
    
    connection_msg db 'New connection recieved', 0xA
    connection_msg_len equ $ - connection_msg
    
    bind_error db 'Error: Could not bind to port (already in use?)', 0xA
    bind_error_len equ $ - bind_error

    ; Socket Address Structure
    sockaddr:
        dw 2            ; AF_INET (address family)
        dw 0x901F       ; PORT 8080 in network byte order (big-endian)
        dd 0            ; INADDR_ANY (0.0.0.0)
        dq 0            ; Padding

; FUTURE DATA
; -----------

section .bss
    request_buffer resb 4096        ; Buffer for incoming HTTP request
    client_addr resb 16             ; Client address structure
    client_addr_len resq 1          ; Length of client address

; -----------
; DEFINITIONS
; -----------

%define SYS_READ    0       ; Syscall: Read
%define SYS_WRITE   1       ; Syscall: Write
%define SYS_SOCKET  41      ; Syscall: Socket
%define SYS_ACCEPT  43      ; Syscall: Accept Connection
%define SYS_BIND    49      ; Syscall: Bind Socket
%define SYS_LISTEN  50      ; Syscall: Listen
%define SYS_EXIT    60      ; Syscall: Exit

%define STDIN  0        ; File Descriptor for STDIN
%define STDOUT 1        ; File Descriptor for STDOUT
%define STDERR 2        ; File Descriptor for STDERR

%define AF_INET     2
%define SOCK_STREAM 1
%define PROTOCOL    0

; ------
; MACROS
; ------

%macro write 2
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %2_len
    syscall
%endmacro

%macro print_msg 1
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, %1_len
    syscall
%endmacro

%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

; =====
; START
; =====

section .text
    global _start

_start:
    ; Print server start message
    print_msg server_start

    ; Create socket: socket(AF_INET, SOCK_STREAM, 0)
    call create_socket

    ; Save socket file descriptor (returned as rax) in r12
    mov r12, rax

    ; Bind socket: bind(socketfd, &sockaddr, sizeof(sockaddr))
    call bind_socket

    ; Listen for connection: listen(socketfd, backlog)
    call listen

.accept_loop:
    ; Accept connection: accept(sockfd, &client_addr, &client_addr_len)
    mov qword [client_addr_len], 16             ; dw (2) + dw (2) + dd (4) + dq (8) = 16

    mov rax, SYS_ACCEPT
    mov rdi, r12                        ; Saved socket file descriptor in R12
    mov rsi, client_addr                ; Client address buffer
    mov rdx, client_addr_len            ; Client address buffer length
    syscall

    ; Check for error
    test rax, rax
    js .accept_loop                     ; On error, try again

    mov r13, rax                        ; Save client socket fd in R13

    ; Print Connection Message
    print_msg connection_msg

    ; Read HTTP request: read(client_fd, buffer, size)
    call read_http_request

    ; This is where we would parse the http request. Keeping it simple for now.

    ; Send HTTP response: write(client_fd, response, length)
    call send_http_response

; CREATE SOCKET
; -------------

; Function: create_socket
; socket(AF_INET, SOCK_STREAM, 0)
create_socket:
    ; Create socket
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, PROTOCOL
    syscall

    ; Check for error
    test rax, rax
    js .error
    ret ; Return RAX if no error

; BIND SOCKET
; -----------

; Function: bind_socket
; bind(socketfd, &socketaddr, sizeof(sockaddr))
bind_socket:
    mov rax, SYS_BIND
    mov rdi, r12            ; Socket File Descriptor Saved in R12
    mov rsi, sockaddr
    mov rdx, 16             ; Size of sockaddr: dw (2) + dw (2) + dd (4) + dq (8) = 16
    syscall

    ; Check for error
    test rax, rax
    js .bind_error
    ret

; LISTEN
; ------

; Function: listen
; listen(socketfd, backlog)
listen:
    mov rax, SYS_LISTEN
    mov rdi, r12            ; Saved socket file-descriptor
    mov rsi, 10             ; Backlog (max queued connections)
    syscall

    ; Check error
    test rax, rax
    js .error
    ret

; READ HTTP REQUEST
; -----------------

; Function: read_http_request
; read(client_fd, buffer, size)
read_http_request:
    mov rax, SYS_READ
    mov rdi, r13                ; Saved client file descriptor
    mov rsi, request_buffer     ; The buffer to save the request in
    mov rdx, 4096               ; Number of bytes reserved for the request
    syscall
    ret

; SEND HTTP RESPONSE
; ------------------

; Function: send_http_response
; write(client_fd, response, length)
send_http_response:
    mov rax, SYS_WRITE
    mov rdi, r13                ; Client file descriptor
    mov rsi, http_response      ; HTTP Response buffer to write
    mov rdx, http_response_len  ; Length of the HTTP response buffer
    syscall
    ret

; ERROR BRANCH
; ------------

.error:
    error

.bind_error:
    write STDERR bind_error
    jmp .exit

; EXIT BRANCH
; -----------

.exit:
    ; Close Server Socket
    mov rax, 3          ; Syscall: Close Socket?
    mov rdi, r12        ; Move socket fd into rdi as the argument
    syscall
    exit 0              ; Exit with status code 0
