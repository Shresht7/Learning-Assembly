# Test Framework

A lightweight test framework for x86-64 Linux NASM assembly, with colored PASS/FAIL output via `print_str` and `print_int` from `stdio.asm`.

## Getting Started

Create a `.test.asm` file in the `library/` directory:

```asm
%include "library/<module>.asm"
%include "library/test-assert.asm"

section .data
    DEFINE_STR my_str, 'hello', 0

section .text

global _start
_start:

    TESTCASE "a short description of the test"

        mov rdi, my_str
        call strlen
        ASSERT_EQ rax, 5, "strlen should return 5 for 'hello'"

    ; Exit with success (note: exit code is always 0, even on failures)
    mov rax, SYSCALL_EXIT
    xor rdi, rdi
    syscall
```

Run with:

```sh
$ ./library/run_tests.sh
```

## Macros

### `TESTCASE <description>`

Prints a named test case group. All assertions inside a test case are indented for readability.

### `ASSERT_EQ <actual>, <expected>, <description>`

Passes if `actual == expected`.

### `ASSERT_NE <actual>, <expected>, <description>`

Passes if `actual != expected`.

### `ASSERT_LT <actual>, <expected>, <description>`

Passes if `actual < expected` (signed).

### `ASSERT_LE <actual>, <expected>, <description>`

Passes if `actual <= expected` (signed).

### `ASSERT_GT <actual>, <expected>, <description>`

Passes if `actual > expected` (signed).

### `ASSERT_GE <actual>, <expected>, <description>`

Passes if `actual >= expected` (signed).

### `ASSERT_TRUE <condition>, <description>`

Passes if `condition == 1`. Note this is **strict equality**, not a general nonzero check. A value like `2` would fail. This is fine when functions return canonical `TRUE` (1) or `FALSE` (0), but not for general truthiness checks.

### `ASSERT_FALSE <condition>, <description>`

Passes if `condition == 0`.

### `ASSERT_STR_EQ <str1>, <str2>, <description>`

Passes if the null-terminated strings at `str1` and `str2` are equal. Internally calls `strcmp`.

## Running Tests

The `run_tests.sh` script finds all `*.test.asm` files, assembles them with `nasm -f elf64`, links with `ld`, and runs each executable.

```sh
$ ./library/run_tests.sh
```

### Limitations

- **Exit code**: All tests exit with code 0 regardless of failures. Failures are reported via printed output only.
- **Output**: `TESTCASE` and assertion output is mixed; there is no summary line at the end showing pass/fail counts.

## Files

| File              | Purpose                                    |
| ----------------- | ------------------------------------------ |
| `test-assert.asm` | Macro definitions (`TESTCASE`, `ASSERT_*`) |
| `*.test.asm`      | Individual test files using the macros     |
| `run_tests.sh`    | Script to compile and run all tests        |
