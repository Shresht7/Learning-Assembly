# "Standard Library"

Everytime I write assembly code, it feels like I'm reinventing C and it's standard library from first principles.

This is a collection of assembly code snippets providing common functionality that I can reuse in my programs, similar to how C has a standard library. I just simply copy-paste the stuff I need.

Goes without saying, **do not** use this for anything serious. This is just a personal project to learn assembly and understand how things work under the hood. tl;dr: skill issues

## Libraries

- [`syscalls`](#syscalls): Linux x86-64 syscalls
- [`stdio`](#stdio): Standard I/O
- [`strutils`](#strutils) String Utilities

---

## SYSCALLS

System calls are the interface between user programs and the operating system kernel. They allow programs to request services from the OS, such as file operations, process control, and communication.

Contains wrappers for common system calls for Linux x86-64, making it easier to perform operations like reading from or writing to files, creating processes, and more.

### Syscall Constants

- `SYSCALL_READ` (0): Read from a file descriptor.
- `SYSCALL_WRITE` (1): Write to a file descriptor.
- `SYSCALL_EXIT` (60): Terminate the calling process.

### File Descriptors

- `STDIN` (0): Standard input.
- `STDOUT` (1): Standard output.
- `STDERR` (2): Standard error.

### Exit Status Codes

- `EXIT_SUCCESS` (0): Successful termination.
- `EXIT_FAILURE` (1): Unsuccessful termination.

### Macros

#### `WRITE <file-descriptor>, <*buffer>, <length>`

Writes data from a buffer to a file descriptor.

##### Parameters:

- _`file-descriptor`_: The file descriptor to write to (e.g., `STDOUT`, `STDERR`)
- _`*buffer`_: Pointer to the buffer containing the data to write
- _`length`_: The number of bytes to write

##### Returns:

- [**`rax`**]: The number of bytes written, or a negative value if an error occurred

#### `READ <file-descriptor>, <*buffer>, <length>`

Reads data from a file descriptor into a buffer.

##### Parameters:

- _`file-descriptor`_: The file descriptor to read from (e.g., `STDIN`)
- _`*buffer`_: Pointer to the buffer where the read data will be stored
- _`length`_: The maximum number of bytes to read

##### Returns:

- [**`rax`**]: The number of bytes read, or a negative value if an error occurred

#### `DEFINE_STR <label>, <string>`

Defines a string in the `.data` section with a corresponding length label.

Note that this must be used in the `.data` section, not in the `.text` section. The length is automatically calculated and stored in a label with the `_len` suffix.

##### Parameters:

- _`label`_: The label for the string
- _`string`_: The string to define

##### Side effect:

Defines the string label and a `<label>_len` constant in the `.data` section.

#### `PRINT <defined-string>`

Prints a defined-string to stdout.

A defined-string is a string defined in `.data` with a `_len` suffix (e.g., `my_string` and `my_string_len`).

##### Parameters:

- _`defined-string`_: The label of a string defined in the `.data` section (must have a `<label>_len` constant)

##### Returns:

- [**`rax`**]: The number of bytes written, or a negative value if an error occurred

#### `ERROR <defined-string>`

Prints a defined-string to stderr.

A defined-string is a string defined in `.data` with a `_len` suffix (e.g., `my_error` and `my_error_len`).

##### Parameters:

- _`defined-string`_: The label of a string defined in the `.data` section (must have a `<label>_len` constant)

##### Returns:

- [**`rax`**]: The number of bytes written, or a negative value if an error occurred

#### `EXIT <status-code>`

Terminates the program with the specified exit code.

##### Parameters:

- _`status-code`_: The exit code to return to the operating system (e.g., `EXIT_SUCCESS`, `EXIT_FAILURE`)

##### Returns:

This macro does not return; it terminates the program.

---

## STDIO

Standard Input/Output functions, similar to C's `stdio.h`. This includes functions for printing to the console, reading input, and handling strings.

### Subroutines

#### `print_str(string rdi: *char)`

Prints a null-terminated string to stdout.

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string

##### Returns:

Nothing.

#### `read_str(buffer rdi: *char, buffer_size rsi: int) -> bytes_read rax: int`

Reads a string from stdin into a buffer.

##### Parameters:

- [**`rdi`**] _`buffer`_: pointer to the buffer where the string will be stored
- [**`rsi`**] _`buffer_size`_: size of the buffer (maximum number of bytes to read)

##### Returns:

- [**`rax`**] _`bytes_read`_: number of bytes read (excluding the null terminator)

#### `print_int(integer rdi: int)`

Prints an integer to stdout.

##### Parameters:

- [**`rdi`**] _`integer`_: integer to print

##### Returns:

Nothing.

### Macros

#### `PRINT_STR <*str>`

Prints a null-terminated string to stdout.

##### Parameters:

- [**`rdi`**] _`str`_: pointer to the null-terminated string (passed to `print_str`)


#### `READ_STR <*buffer>, <length>`

Reads a string from stdin into a buffer.

##### Parameters:

- [**`rdi`**] _`buffer`_: pointer to the buffer where the string will be stored (passed to `read_str`)
- [**`rsi`**] _`length`_: size of the buffer (passed to `read_str`)

##### Returns:

- [**`rax`**] _`bytes_read`_: number of bytes read (excluding the null terminator)

---

## STRUTILS

String manipulation utilities, similar to C's `string.h`. This includes functions for string length, comparison, and copying.

### Subroutines


#### `strlen(string rdi: *char) -> length rax: int`

Returns the length of a null-terminated string

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string

##### Returns:

- [**`rax`**] _`length`_: length of the string (not including the null terminator)


#### `is_empty(string rdi: *char) -> yes rax: int`

Checks if a null-terminated string is empty

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string

##### Returns:

- [**`rax`**] _`yes`_:
  - `1`: The string is empty
  - `0`: The string is not empty


#### `strcmp(str1 rdi: *char, str2 rsi: *char) -> result rax: int`

Compares two null-terminated strings

##### Parameters:

- [**`rdi`**] _`str1`_: pointer to the first null-terminated string
- [**`rsi`**] _`str2`_: pointer to the second null-terminated string

##### Returns:

- [**`rax`**] _`result`_:
  - `0`: The strings are equal
  - `<0`: The first string is less than the second string
  - `>0`: The first string is greater than the second string


#### `is_digit(char rdi: char) -> yes rax: int`

Checks if a character is a digit (0-9)

##### Parameters:

- [**`rdi`**] _`char`_: character to check

##### Returns:

- [**`rax`**] _`yes`_:
  - `1`: The character is a digit
  - `0`: The character is not a digit


#### `is_uppercase(char rdi: char) -> yes rax: int`

Checks if a character is an uppercase letter (A-Z)

##### Parameters:

- [**`rdi`**] _`char`_: character to check

##### Returns:

- [**`rax`**] _`yes`_:
  - `1`: The character is an uppercase letter
  - `0`: The character is not an uppercase letter


#### `is_lowercase(char rdi: char) -> yes rax: int`

Checks if a character is a lowercase letter (a-z)

##### Parameters:

- [**`rdi`**] _`char`_: character to check

##### Returns:

- [**`rax`**] _`result`_:
  - `1`: The character is a lowercase letter
  - `0`: The character is not a lowercase letter


#### `is_alphanumeric(char rdi: char) -> yes rax: int`

Checks if a character is alphanumeric (0-9, A-Z, a-z)

##### Parameters:

- [**`rdi`**] _`char`_: character to check

##### Returns:

- [**`rax`**] _`yes`_:
  - `1`: The character is alphanumeric
  - `0`: The character is not alphanumeric


#### `itoa(integer rdi: int, buffer rsi: *char) -> string rax: *char`

Converts an integer to a null-terminated string

##### Parameters:

- [**`rdi`**] _`integer`_: integer to convert
- [**`rsi`**] _`buffer`_: pointer to the buffer where the string will be stored

##### Returns:

- [**`rax`**] _`string`_: pointer to the null-terminated string


#### `atoi(string rdi: *char) -> integer rax: int`

Converts a null-terminated string to an integer

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string

##### Returns:

- [**`rax`**] _`integer`_: the converted integer value


#### `base_to_str(integer rdi: int, buffer rsi: *char, base rdx: int) -> string rax: *char`

Converts an integer to a null-terminated string in the specified base (2 to 36)

##### Parameters:

- [**`rdi`**] _`integer`_: integer to convert
- [**`rsi`**] _`buffer`_: pointer to the buffer where the string will be stored
- [**`rdx`**] _`base`_: base for conversion (between 2 and 36)

##### Returns:

- [**`rax`**] _`string`_: pointer to the null-terminated string


#### `str_to_base(string rdi: *char, base rsi: int) -> integer rax: int`

Converts a string in the specified base (2-36) to an integer

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string
- [**`rsi`**] _`base`_: base of the string representation (between 2 and 36)

##### Returns:

- [**`rax`**] _`integer`_: the converted integer value, or 0 if an error occurred


#### `strcpy(dest rdi: *char, src rsi: *char) -> dest rax: *char`

Copies a null-terminated string from the source to the destination.

##### Parameters:

- [**`rdi`**] _`dest`_: pointer to the destination buffer
- [**`rsi`**] _`src`_: pointer to the source string

##### Returns:

- [**`rax`**] _`dest`_: pointer to the destination buffer


#### `strncpy(dest rdi: *char, src rsi: *char, n rdx: int) -> dest rax: *char`

Copies up to `n` characters from the source string to the destination

##### Parameters:

- [**`rdi`**] _`dest`_: pointer to the destination buffer
- [**`rsi`**] _`src`_: pointer to the source string
- [**`rdx`**] _`n`_: maximum number of characters to copy

##### Returns:

- [**`rax`**] _`dest`_: pointer to the destination buffer


#### `strcat(dest rdi: *char, src rsi: *char) -> dest rax: *char`

Appends the source string to the end of the destination string

##### Parameters:

- [**`rdi`**] _`dest`_: pointer to the destination buffer
- [**`rsi`**] _`src`_: pointer to the source string

##### Returns:

- [**`rax`**] _`dest`_: pointer to the destination buffer


#### `strncat(dest rdi: *char, src rsi: *char, n rdx: int) -> dest rax: *char`

Appends up to `n` characters from the source string to the end of the destination string.

##### Parameters:

- [**`rdi`**] _`dest`_: pointer to the destination buffer
- [**`rsi`**] _`src`_: pointer to the source string
- [**`rdx`**] _`n`_: maximum number of characters to append

##### Returns:

- [**`rax`**] _`dest`_: pointer to the destination buffer


#### `strfindchar(string rdi: *char, char rsi: char) -> index rax: int`

Finds the first occurrence of a character in a null-terminated string.

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string
- [**`rsi`**] _`char`_: character to search for

##### Returns:

- [**`rax`**] _`index`_: index of the first occurrence of the character, or `-1` if not found


#### `strstartswith(string rdi: *char, prefix rsi: *char) -> yes rax: int`

Checks if a null-terminated string starts with a specified prefix

##### Parameters:

- [**`rdi`**] _`string`_: pointer to the null-terminated string
- [**`rsi`**] _`prefix`_: pointer to the prefix string to check for

##### Returns:

- [**`rax`**] _`yes`_:
  - `1`: The string starts with the specified prefix
  - `0`: The string does not start with the specified prefix

##### Example:

```asm
section .data
    ; Null-terminated strings
    my_string db "Hello, World!", 0
    my_prefix db "Hello", 0

section .text
    ; Check if my_string starts with my_prefix
    mov rdi, my_string
    mov rsi, my_prefix
    call strstartswith

    ; rax will be 1 if my_string starts with my_prefix, 0 otherwise
    cmp rax, 1
    je .starts_with
    jne .does_not_start_with
```
