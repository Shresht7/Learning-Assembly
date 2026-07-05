%ifndef STRUTILS_ASM
%define STRUTILS_ASM

; ----------------
; STRING UTILITIES
; ----------------

section .data
    charset db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"  ; Character set for base conversion (up to base 36)

section .text


    ;;; `strlen(string rdi: *char) -> length rax: int`
    ;;;
    ;;; Returns the length of a null-terminated string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;
    ;;; Returns:
    ;;;   * [rax] length: length of the string (not including the null terminator)
    strlen:
        mov rax, 0                          ; Initialize length counter to 0
        .strlen_loop:
            cmp byte [rdi + rax], 0         ; Compare the current byte (at memory address rdi (start) + rax (counter)) with the null terminator
            je .strlen_done                 ; Jump if equal (found null terminator) to the `.strlen_done` label
            inc rax                         ; Otherwise, increment the length counter
            jmp .strlen_loop                ; Jump back to the start of the loop for the next byte/character
        .strlen_done:
            ret                             ; Return from the function, with rax containing the length of the string



    ;;; `is_empty(string rdi: *char) -> yes rax: int`
    ;;;
    ;;; Checks if a null-terminated string is empty
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the string is empty, 0 otherwise
    is_empty:
        cmp byte [rdi], 0                   ; Compare the first byte of the string with the null terminator
        je .is_empty_true                   ; If equal, the string is empty, jump to `.is_empty_true`
        mov rax, 0                          ; Otherwise, set rax to 0 (false)
        ret
        .is_empty_true:
            mov rax, 1                      ; Set rax to 1 (true)
            ret



    ;;; `strcmp(str1 rdi: *char, str2 rsi: *char) -> result rax: int`
    ;;;
    ;;; Compares two null-terminated strings
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] str1: pointer to the first null-terminated string
    ;;;   * [rsi] str2: pointer to the second null-terminated string
    ;;;
    ;;; Returns:
    ;;;   * [rax] result: 0 if the strings are equal, <0 if str1 < str2, >0 if str1 > str2
    strcmp:
        xor rax, rax                        ; Clear rax to use it as a result accumulator
        .strcmp_loop:
            mov al, byte [rdi]              ; Load the current byte of str1 into al
            mov bl, byte [rsi]              ; Load the current byte of str2 into bl
            cmp al, bl                      ; Compare the two bytes
            jl .strcmp_less                 ; If str1 < str2, jump to the `.strcmp_less` label
            jg .strcmp_greater              ; If str1 > str2, jump to the `.strcmp_greater` label
            test al, al                     ; Check if we reached the null terminator of str1 (and str2, since they are equal so far)
            je .strcmp_equal                 ; If we reached the null terminator, the strings are equal, jump to the `.strcmp_equal` label
            inc rdi                         ; Move to the next byte in str1
            inc rsi                         ; Move to the next byte in str2
            jmp .strcmp_loop                ; Jump back to the start of the loop for the next comparison
        .strcmp_less:
            mov rax, -1                     ; Set rax to -1 to indicate str1 < str2
            ret                             
        .strcmp_greater:
            mov rax, 1                      ; Set rax to 1 to indicate str1 > str2
            ret                             
        .strcmp_equal:
            xor rax, rax                    ; Set rax to 0 to indicate str1 == str2
            ret                             



    ;;; `is_digit(char rdi: char) -> yes rax: int`
    ;;;
    ;;; Checks if a character is a digit (0-9)
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] char: character to check
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the character is a digit, 0 otherwise
    is_digit:
        xor rax, rax                        ; Assume false (not a digit)
        cmp rdi, '0'                        ; Compare the character with '0'
        jl .not_digit                       ; If less than '0', it's not a digit
        cmp rdi, '9'                        ; Compare the character with '9'
        jg .not_digit                       ; If greater than '9', it's not a digit
        mov rax, 1                          ; If we reach here, it's a digit, set rax to 1 (true)
        ret
        .not_digit:
            ret                             ; Return from the function, with rax containing the result (1 for digit, 0 for not a digit)



    ;;; `is_uppercase(char rdi: char) -> yes rax: int`
    ;;;
    ;;; Checks if a character is an uppercase letter (A-Z)
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] char: character to check
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the character is an uppercase letter, 0 otherwise
    is_uppercase:
        xor rax, rax                        ; Assume false (not an uppercase letter)
        cmp rdi, 'A'                        ; Compare the character with 'A'
        jl .not_uppercase                   ; If less than 'A', it's not an uppercase letter
        cmp rdi, 'Z'                        ; Compare the character with 'Z'
        jg .not_uppercase                   ; If greater than 'Z', it's not an uppercase letter
        mov rax, 1                          ; If we reach here, it's an uppercase letter, set rax to 1 (true)
        ret
        .not_uppercase:
            ret                             ; Return from the function, with rax containing the result (1 for uppercase, 0 for not an uppercase)



    ;;; `is_lowercase(char rdi: char) -> yes rax: int`
    ;;;
    ;;; Checks if a character is a lowercase letter (a-z)
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] char: character to check
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the character is a lowercase letter, 0 otherwise
    is_lowercase:
        xor rax, rax                        ; Assume false (not a lowercase letter)
        cmp rdi, 'a'                        ; Compare the character with 'a'
        jl .not_lowercase                   ; If less than 'a', it's not a lowercase letter
        cmp rdi, 'z'                        ; Compare the character with 'z'
        jg .not_lowercase                   ; If greater than 'z', it's not a lowercase letter
        mov rax, 1                          ; If we reach here, it's a lowercase letter, set rax to 1 (true)
        ret
        .not_lowercase:
            ret                             ; Return from the function, with rax containing the result (1 for lowercase, 0 for not a lowercase)



    ;;; `is_alphanumeric(char rdi: char) -> yes rax: int`
    ;;;
    ;;; Checks if a character is alphanumeric (0-9, A-Z, a-z)
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] char: character to check
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the character is alphanumeric, 0 otherwise
    is_alphanumeric:
        call is_digit                       ; Check if the character is a digit
        cmp rax, 1                          ; Compare the result with 1 (true)
        je .is_alphanumeric_true            ; If true, jump to `.is_alphanumeric_true`
        call is_uppercase                   ; Check if the character is an uppercase letter
        cmp rax, 1                          ; Compare the result with 1 (true)
        je .is_alphanumeric_true            ; If true, jump to `.is_alphanumeric_true`
        call is_lowercase                   ; Check if the character is a lowercase letter
        cmp rax, 1                          ; Compare the result with 1 (true)
        je .is_alphanumeric_true            ; If true, jump to `.is_alphanumeric_true`
        xor rax, rax                        ; If none of the checks passed, set rax to 0 (false)
        ret
        .is_alphanumeric_true:
            mov rax, 1                      ; Set rax to 1 (true) if the character is alphanumeric
            ret



    ;;; `itoa(integer rdi: int, buffer rsi: *char) -> string rax: *char`
    ;;;
    ;;; Converts an integer to a null-terminated string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] integer: integer to convert
    ;;;   * [rsi] buffer: pointer to the buffer where the string will be stored
    ;;;
    ;;; Returns:
    ;;;   * [rax] string: pointer to the null-terminated string
    itoa:
        mov rax, rdi                    ; Move the integer into rax for processing
        mov rcx, 10                     ; Set the divisor to 10 for decimal conversion
        mov r8, 0                       ; Initialize a counter for the number of digits

        .divide_loop:
            xor rdx, rdx                ; Clear rdx before division (to hold the remainder)
            div rcx                     ; Divide rax by 10, quotient in rax, remainder in rdx

            add dl, '0'                 ; Convert the remainder (0-9) to ASCII ('0'-'9')
                                        ; (dl is the lowest 8 bits of the rdx register)

            push rdx                    ; Push the ASCII character onto the stack (we'll have to reverse the order later 
                                        ;as we build the string from least significant digit to most significant digit)
            inc r8                      ; Increment the digit counter
 
            cmp rax, 0                  ; Check if the quotient is zero (we've processed all digits)
            jne .divide_loop            ; If not zero, continue the loop to process the next digit

        ; Now we have all digits on the stack in reverse order, and r8 contains the number of digits
        ; We will now pop the digits from the stack and store them in the buffer pointed to by rsi

        .store_loop:
            pop rdx                     ; Pop the next digit from the stack into rdx
            mov [rsi], dl               ; Store the ASCII character in the buffer
            inc rsi                     ; Move to the next position in the buffer
            dec r8                      ; Decrement the digit counter
            cmp r8, 0                   ; Check if we have processed all digits
            jne .store_loop             ; If not, continue storing the next digit

        ; Null-terminate the string
        mov byte [rsi], 0               ; Store the null terminator at the end
        ret                             ; Return from the function, with the string stored in the buffer pointed to by rsi


    ;;; `atoi(string rdi: *char) -> integer rax: int`
    ;;;
    ;;; Converts a null-terminated string to an integer
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;
    ;;; Returns:
    ;;;   * [rax] integer: the converted integer value
    atoi:
        xor rax, rax                    ; Clear rax to use it as the result accumulator

        xor rbx, rbx                    ; Clear rbx to use it as a temporary variable for the current digit
        .atoi_loop:
            mov bl, byte [rdi]              ; Load the current byte of the string into
            cmp bl, 0                       ; Check if we reached the null terminator
            je .atoi_done                   ; If we reached the null terminator, jump to the `.atoi_done` label

            sub bl, '0'                     ; Convert the ASCII character to its integer value by subtracting '0'
            imul rax, rax, 10               ; Multiply the current result by 10 to shift left for the next digit
            add rax, rbx                    ; Add the current digit to the result

            inc rdi                         ; Move to the next byte in the string
            jmp .atoi_loop                  ; Jump back to the start of the loop for the next character
        .atoi_done:
            ret                             ; Return from the function, with rax containing the converted integer value



    ;;; `base_to_str(integer rdi: int, buffer rsi: *char, base rdx: int) -> string rax: *char`
    ;;;
    ;;; Converts an integer to a null-terminated string in the specified base (2 to 36)
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] integer: integer to convert
    ;;;   * [rsi] buffer: pointer to the buffer where the string will be stored
    ;;;   * [rdx] base: base for conversion (between 2 and 36)
    ;;;
    ;;; Returns:
    ;;;   * [rax] string: pointer to the null-terminated string
    base_to_str:
        mov rax, rdi                        ; Move the integer into rax for processing
        mov rcx, rdx                        ; Move the base into rcx for division
        mov r8, 0                           ; Initialize a counter for the number of digits
        lea r10, [rel charset]              ; Load the address of the character set into r10

        .divide_loop:
            xor rdx, rdx                    ; Clear rdx before division (to hold the remainder)
            div rcx                         ; Divide rax by the base, quotient in rax, remainder in rdx

            ; Lookup the character corresponding to the remainder in the character set
            ; rdx is our remainder, which is the index into the character set
            movzx r11, byte [r10 + rdx]     ; Get the character corresponding to the remainder from the character set

            push r11                        ; Push the character onto the stack (we'll have to reverse the order later)
            inc r8                          ; Increment the digit counter

            cmp rax, 0                      ; Check if the quotient is zero (we've processed all digits)
            jne .divide_loop                ; If not zero, continue the loop to process the next digit

        ; Now we have all digits on the stack in reverse order, and r8 contains the number of digits
        ; We will now pop the digits from the stack and store them in the buffer pointed to by rsi
        .store_loop:
            pop r11                         ; Pop the next character from the stack into r11
            mov [rsi], r11b                 ; Store the character in the buffer (use 11b to store only the lowest byte)
            inc rsi                         ; Move to the next position in the buffer
            dec r8                          ; Decrement the digit counter
            cmp r8, 0                       ; Check if we have processed all digits
            jne .store_loop                 ; If not, continue storing the next character
            
        ; Null-terminate the string
        mov byte [rsi], 0                   ; Store the null terminator at the end
        ret                                 ; Return from the function, with the string stored in the buffer pointed to by



    ;;; `str_to_base(string rdi: *char, base rsi: int) -> integer rax: int`
    ;;;
    ;;; Converts a string in the specified base (2-36) to an integer
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;   * [rsi] base: base of the string representation (between 2 and 36)
    ;;;
    ;;; Returns:
    ;;;   * [rax] integer: the converted integer value, or 0 if an error occurred
    str_to_base:
        ; Save the registers that we will use to avoid overwriting any important values
        push r12
        push r13
        push r14

        xor r12, r12                        ; r12 = Accumulator
        mov r13, rsi                        ; r13 = Base

        .multiply_loop:
            movzx r14, byte [rdi]           ; Safely load 1 byte into r14 from the string (rdi points to the current character in the string)
            cmp r14, 0                      ; Check if we reached the null terminator
            je .str_to_base_done            ; If we reached the null terminator, jump to the `.str_to_base_done` label

            ; Check if it is alphanumeric
            push rdi                        ; Save rdi on the stack to preserve the pointer to the string 
            mov rdi, r14                     ; Move the character to rdi for the is_alphanumeric check
            call is_alphanumeric            ; Call the is_alphanumeric function to check if the character is alphanumeric
            pop rdi                         ; Restore rdi from the stack
            cmp rax, 1                      ; Check the result of is_alphanumeric (rax will be 1 if the character is alphanumeric, 0 otherwise)
            jne .str_to_base_error          ; If not alphanumeric, jump to the `.str_to_base_error` label

            ; Check if it is a digit
            push rdi                        ; Save rdi on the stack to preserve the pointer to the string
            mov rdi, r14                     ; Move the character to rdi for the is_digit check
            call is_digit                   ; Call the is_digit function to check if the character is a digit
            pop rdi                         ; Restore rdi from the stack
            cmp rax, 1                      ; Check the result of is_digit (rax will be 1 if the character is a digit, 0 otherwise)
            je .str_to_base_digit           ; If not a digit, check if it is an uppercase letter

            ; Check if it is an uppercase letter
            push rdi                        ; Save rdi on the stack to preserve the pointer to the string
            mov rdi, r14                     ; Move the character to rdi for the is_uppercase check
            call is_uppercase               ; Call the is_uppercase function to check if the character is an uppercase letter
            pop rdi                         ; Restore rdi from the stack
            cmp rax, 1                      ; Check the result of is_uppercase (rax will be 1 if the character is an uppercase letter, 0 otherwise)
            je .str_to_base_uppercase       ; If not an uppercase letter, check if it is a lowercase letter

            ; If it is valid, and not a digit or uppercase letter, it must be a lowercase letter
            jmp .str_to_base_lowercase

            .str_to_base_digit:
            sub r14, '0'                     ; Convert the ASCII character to its integer value by subtracting '0'
            jmp .str_to_base_process

            .str_to_base_uppercase:
            sub r14, 'A'                     ; Convert the ASCII character to its integer value by subtracting 'A' (A-Z to 0-25)
            add r14, 10                      ; Adjust the value to account for the digits (0-9) that come before the letters in the base representation
            jmp .str_to_base_process

            .str_to_base_lowercase:
            sub r14, 'a'                     ; Convert the ASCII character to its integer value by subtracting 'a' (a-z to 0-25)
            add r14, 10                      ; Adjust the value to account for the digits (0-9) that come before the letters in the base representation
            jmp .str_to_base_process

            .str_to_base_process:
            cmp r14, r13                     ; Is the translated digit >= base?
            jge .str_to_base_error          ; If so, jump to the `.str_to_base_error` label

            imul r12, r13                    ; Multiply the current result by the base
            add r12, r14                      ; Add the current digit to the result
            
            inc rdi                         ; Move to the next character in the string
            jmp .multiply_loop              ; Jump back to the start of the loop for the next character

        .str_to_base_error:
            xor rax, rax                    ; Clear rax to indicate an error (return 0)
            jmp .epilogue

        .str_to_base_done:
            mov rax, r12                     ; Move the final result into rax for return
            jmp .epilogue

        .epilogue:
            pop r14                         ; Restore r14
            pop r13                         ; Restore r13
            pop r12                         ; Restore r12
            ret                             ; Return from the function, with rax containing the converted integer value (or 0 in case of an error)


    ;;; `strcpy(dest rdi: *char, src rsi: *char) -> dest rax: *char`
    ;;;
    ;;; Copies a null-terminated string from the source to the destination
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] dest: pointer to the destination string
    ;;;   * [rsi] src: pointer to the source string
    ;;;
    ;;; Returns:
    ;;;   * [rax] dest: pointer to the destination string
    strcpy:
        mov rax, rdi                        ; Save the destination pointer in rax for return
        .copy_loop:
            mov bl, byte [rsi]              ; Load the current character from the source string
            mov byte [rdi], bl              ; Store the character in the destination string
            inc rsi                         ; Move to the next character in the source string
            inc rdi                         ; Move to the next position in the destination string
            cmp bl, 0                       ; Check if we reached the null terminator in the source
            jne .copy_loop                  ; If not, jump back to the start of the loop for the next character
        mov byte [rdi], 0                  ; Null-terminate the destination string
        ret                                 ; Return from the function, with rax containing the pointer to the destination string


    ;;; `strncpy(dest rdi: *char, src rsi: *char, n rdx: int) -> dest rax: *char`
    ;;;
    ;;; Copies up to n characters from the source string to the destination string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] dest: pointer to the destination string
    ;;;   * [rsi] src: pointer to the source string
    ;;;   * [rdx] n: maximum number of characters to copy
    ;;;
    ;;; Returns:
    ;;;   * [rax] dest: pointer to the destination string
    strncpy:
        mov rax, rdi                        ; Save the destination pointer in rax for return
        xor rcx, rcx                        ; Clear rcx to use it as a counter

        .copy_loop:
            cmp rcx, rdx                    ; Check if we have copied n characters
            jge .copy_done                  ; If we have copied n characters, jump to `.copy_done`
            
            mov bl, byte [rsi + rcx]        ; Load the current character from the source string
            mov byte [rdi + rcx], bl        ; Store the character in the destination string
            inc rcx                         ; Increment the counter
            cmp bl, 0                       ; Check if we reached the null terminator in the source
            je .copy_done                   ; If we reached the null terminator, jump to `.copy_done`
            jmp .copy_loop                  ; Jump back to the start of the loop for the next character

        .copy_done:
            mov byte [rdi + rcx], 0         ; Null-terminate the destination string
            ret                             ; Return from the function, with rax containing the pointer to the destination string



    ;;; `strcat(dest rdi: *char, src rsi: *char) -> dest rax: *char`
    ;;;
    ;;; Concatenates the source string to the end of the destination string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] dest: pointer to the destination string
    ;;;   * [rsi] src: pointer to the source string
    ;;;
    ;;; Returns:
    ;;;   * [rax] dest: pointer to the destination string
    strcat:
        mov rax, rdi                        ; Save the destination pointer in rax for return
        ; Find the end of the destination string
        .find_end:
            cmp byte [rdi], 0               ; Check if we reached the null terminator
            je .copy_src                    ; If we reached the null terminator, jump to `.copy_src` to start copying the source string
            inc rdi                         ; Move to the next character in the destination string
            jmp .find_end                   ; Jump back to the start of the loop to find the end of the destination string

        .copy_src:
            mov bl, byte [rsi]              ; Load the current character from the source string
            mov byte [rdi], bl              ; Store the character in the destination string
            inc rsi                         ; Move to the next character in the source string
            inc rdi                         ; Move to the next position in the destination string
            cmp bl, 0                       ; Check if we reached the null terminator in the source
            jne .copy_src                   ; If not, jump back to the start of the loop to copy the next character
            ret                             ; Return from the function, with rax containing the pointer



    ;;; `strncat(dest rdi: *char, src rsi: *char, n rdx: int) -> dest rax: *char`
    ;;;
    ;;; Concatenates up to n characters from the source string to the end of the destination string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] dest: pointer to the destination string
    ;;;   * [rsi] src: pointer to the source string
    ;;;   * [rdx] n: maximum number of characters to concatenate
    ;;;
    ;;; Returns:
    ;;;   * [rax] dest: pointer to the destination string
    strncat:
        mov rax, rdi                        ; Save the destination pointer in rax for return
        ; Find the end of the destination string
        .find_end:
            cmp byte [rdi], 0               ; Check if we reached the null terminator
            je .copy_src                    ; If we reached the null terminator, jump to `.copy_src` to start copying the source string
            inc rdi                         ; Move to the next character in the destination string
            jmp .find_end                   ; Jump back to the start of the loop to find the end of the destination string

        .copy_src:
            cmp rdx, 0                      ; Check if we have copied n characters
            je .null_terminate              ; If we have copied n characters, jump to `.null_terminate` to null-terminate the destination string
            mov bl, byte [rsi]              ; Load the current character from the source string
            cmp bl, 0                       ; Check if we reached the null terminator in the source
            je .null_terminate              ; If we reached the null terminator, jump to `.null_terminate` to null-terminate the destination string
            mov byte [rdi], bl              ; Store the character in the destination string
            inc rsi                         ; Move to the next character in the source string
            inc rdi                         ; Move to the next position in the destination string
            dec rdx                         ; Decrement the counter for the number of characters to concatenate
            jmp .copy_src                   ; Jump back to the start of the loop to copy the next character

        .null_terminate:
            mov byte [rdi], 0               ; Null-terminate the destination string
            ret                             ; Return from the function, with rax containing the pointer to the destination string

        


    ;;; `strfindchar(string rdi: *char, char rsi: char) -> index rax: int`
    ;;;
    ;;; Searches for the first occurrence of a character in a null-terminated string
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;   * [rsi] char: character to search for
    ;;;
    ;;; Returns:
    ;;;   * [rax] index: index of the first occurrence of the character, or -1 if not found
    strfindchar:
        xor rax, rax                        ; Clear rax to use it as an index counter
        .search_loop:
            cmp byte [rdi + rax], 0         ; Check if we reached the null terminator
            je .not_found                   ; If we reached the null terminator, jump to `.not_found`
            cmp byte [rdi + rax], sil       ; Compare the current character with the search character (sil is the lower 8 bits of rsi)
            je .found                       ; If they are equal, jump to `.found`
            inc rax                         ; Increment the index counter
            jmp .search_loop                ; Jump back to the start of the loop for the next character
        .found:
            ret                             ; Return from the function, with rax containing the index of the first occurrence
        .not_found:
            mov rax, -1                     ; Set rax to -1 to indicate that the character was not found
            ret                             ; Return from the function, with rax containing -1  



    ;;; `strstartswith(string rdi: *char, prefix rsi: *char) -> yes rax: int`
    ;;;
    ;;; Checks if a null-terminated string starts with a given prefix
    ;;;
    ;;; Parameters:
    ;;;   * [rdi] string: pointer to the null-terminated string
    ;;;   * [rsi] prefix: pointer to the prefix string to check for
    ;;;
    ;;; Returns:
    ;;;   * [rax] yes: 1 if the string starts with the prefix, 0 otherwise
    strstartswith:
        .check_loop:
            mov al, byte [rdi]              ; Load the current character from the string
            mov bl, byte [rsi]              ; Load the current character from the prefix
            cmp bl, 0                       ; Check if we reached the null terminator of the prefix
            je .prefix_matched              ; If we reached the null terminator of the prefix, the prefix is matched, jump to `.prefix_matched`
            cmp al, 0                       ; Check if we reached the null terminator of the string
            je .prefix_not_matched          ; If we reached the null terminator of the string before the prefix, the prefix is not matched, jump to `.prefix_not_matched`
            cmp al, bl                      ; Compare the current characters of the string and the prefix
            jne .prefix_not_matched         ; If they are not equal, the prefix is not matched, jump to `.prefix_not_matched`
            inc rdi                         ; Move to the next character in the string
            inc rsi                         ; Move to the next character in the prefix
            jmp .check_loop                 ; Jump back to the start of the loop for the next character comparison
        .prefix_matched:
            mov rax, 1                      ; Set rax to 1 to indicate that the string starts with the prefix
            ret                             ; Return from the function, with rax containing 1
        .prefix_not_matched:
            xor rax, rax                    ; Clear rax to indicate that the string does not start with the prefix
            ret                             ; Return from the function, with rax containing 0

%endif; STRUTILS_ASM
