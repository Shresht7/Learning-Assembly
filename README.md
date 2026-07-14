# Learning Assembly

**Assembly** is the _lowest-level human-readable programming language_. It maps directly to machine code, the binary instructions that the CPU executes. Each assembly instruction typically corresponds to one CPU operation.

## Machine Code

Machine code is the set of binary instructions that a CPU can execute directly. It consists of sequences of 0s and 1s, which represent specific operations and data. Each CPU architecture has its own unique machine code instruction set.

A CPU only understands 0s and 1s. Each operation has a unique binary representation, known as an **opcode**. For example, on x86-64:

| Hex bytes        | Assembly     | Meaning                     |
| ---------------- | ------------ | --------------------------- |
| `b8 01 00 00 00` | `mov eax, 1` | Load the value 1 into `EAX` |
| `0f 05`          | `syscall`    | Invoke the kernel           |

Taking `b8 01 00 00 00` byte by byte:
- `b8` is the opcode for "load a 32-bit immediate into `EAX`"
- `01 00 00 00` is the value `1` stored in **little-endian** format (least significant byte first). In memory the bytes are `01`, then `00`, `00`, `00`; read as a 32-bit integer this is `0x00000001`.

A more complex example from the `objdump` output below:

```
40100a:  48 be 00 20 40 00 00 00 00 00   movabs $0x402000,%rsi
```

- `48` is a **REX prefix** byte that tells the CPU "this is a 64-bit operation using the extended register set"
- `be` is the opcode for "load a 64-bit immediate into `RSI`"
- `00 20 40 00 00 00 00 00` is the address `0x402000` in little-endian

Every instruction is just bytes. The CPU reads them, decodes the opcode and operands, and executes the operation.

## Assembly Code

Assembly language replaces raw byte sequences with human-readable **mnemonics** (`mov`, `add`, `syscall`). An **assembler** (like NASM) translates these mnemonics into machine code bytes.

Three important things the assembler does for you:

**Labels to addresses.** When you write `_start:`, the assembler records the address of that label. When you later write `jmp _start`, it computes the relative offset from the jump instruction to the label and encodes it as bytes.

```asm
; The assembler computes: jmp to (address of _start) - (address after jmp instruction)
; and encodes that difference into the instruction bytes
_start:
    ...
    jmp _start
```

**Relative offsets for jumps.** Conditional jumps like `je` don't encode the target address directly. They encode a signed offset relative to the next instruction. This means the same machine code can be relocated to any address without modification (position-independent code).

**Operand encoding via ModR/M.** Instructions that operate on two registers or memory locations use a **ModR/M** byte that encodes the addressing mode, register operands, and any displacement. For example, `mov [rax], rbx` has a different ModR/M byte than `mov [rcx], rdx`. The assembler picks the right byte based on your operands.

---

## Repository

### Requirements

You need an **assembler** to turn your _code_ ("text") into machine code, and a **linker** to turn that machine code into an executable file that the operating system can run.

- `nasm`: The **Netwide Assembler**, a popular assembler for x86 architecture. Uses ***Intel*** syntax, which is generally considered easier to read.
- `ld`: The **GNU linker**, which combines object files into a single executable.

Nice to have:

- `gdb`: The **GNU Debugger**, a powerful tool for debugging programs. It allows you to inspect the state of a program while it's running or after it crashes.

```sh
sudo dnf install nasm binutils gdb
```

### To compile the `.asm` files

```sh
nasm -f elf64 ./src/hello.asm -o ./obj/hello.o
```

Compilation converts your assembly code into an **object file** (`.o`). The object file contains the assembled machine code, but it is not yet a complete executable. Here is what is inside:

- **Machine code bytes** for each instruction, already encoded
- **A symbol table** listing labels (like `_start`, `message`) and their offsets within the file
- **Relocation entries** for any reference whose final address isn't known yet

If you disassemble an object file, you will see placeholder addresses (all zeros) because the final memory layout has not been decided:

```sh
objdump -d hello.o
```

```
hello.o:     file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <_start>:
   0:   b8 01 00 00 00          mov    $0x1,%eax
   5:   bf 01 00 00 00          mov    $0x1,%edi
   a:   48 be 00 00 00 00 00    movabs $0x0,%rsi
  11:   00 00 00
  14:   ba 0e 00 00 00          mov    $0xe,%edx
  19:   0f 05                   syscall
  1b:   b8 3c 00 00 00          mov    $0x3c,%eax
  20:   bf 00 00 00 00          mov    $0x0,%edi
  25:   0f 05                   syscall
```

Notice `movabs $0x0,%rsi` at offset `a` and the zeros in the machine code bytes `00 00 00 00 00 00 00 00`. The string address has not been filled in yet. To see what needs to be resolved, use the relocation table:

```sh
objdump -r hello.o
```

```
RELOCATION RECORDS FOR [.text]:
OFFSET           TYPE              VALUE
000000000000000a R_X86_64_64       message
```

This tells you: at offset `0xa` in the `.text` section, fill in the absolute address of the `message` label.

> [!NOTE]
> The `-f elf64` flag tells NASM to generate a 64-bit ELF object file. On 32-bit Linux use `-f elf32`. On Windows: `-f win64` or `-f win32`.

### To link the object files into an executable

```sh
ld ./obj/hello.o -o ./out/hello
```

**Linking** is the process that turns one or more object files into a runnable executable. The linker does three things:

1. **Collects sections** from all input `.o` files and merges them into the output
2. **Resolves relocations** by replacing placeholder addresses with the final memory addresses
3. **Assigns load addresses** (e.g., `.text` at `0x401000`, `.data` at `0x402000`)

Disassemble the linked executable and the placeholders are gone:

```
0000000000401000 <_start>:
  401000:       b8 01 00 00 00          mov    $0x1,%eax
  401005:       bf 01 00 00 00          mov    $0x1,%edi
  40100a:       48 be 00 20 40 00 00    movabs $0x402000,%rsi
  401011:       00 00 00
  401014:       ba 0e 00 00 00          mov    $0xe,%edx
  401019:       0f 05                   syscall
  40101b:       b8 3c 00 00 00          mov    $0x3c,%eax
  401020:       bf 00 00 00 00          mov    $0x0,%edi
  401025:       0f 05                   syscall
```

Now `message` is at `0x402000` and the `movabs` instruction correctly encodes that address.

### To run the compiled binary

```sh
./out/hello
```

> [!NOTE]
> If you take a look at the file-size of the executable (using `ls -lh hello`), you'll notice that it is absolutely tiny compared to anything written in C, Python, or Go etc. It contains nothing but the exact CPU instructions you wrote.

### To debug with GDB, compile with debug symbols:

```sh
# Add -g flag for debug info
nasm -f elf64 -g -F dwarf debug_test.asm -o debug_test.o
ld debug_test.o -o debug_test
```

- `-g`: Include debug info
- `-F dwarf`: Use DWARF debug format

Then run GDB:

```sh
gdb ./debug_test
```

See [`GDB.md`](./GDB.md) for more information.

### To look at the raw machine code

You can use a hex-dump or hex-editor utility to inspect the actual binary contents of the compiled executable.

```sh
xxd hello
```

it looks something like

```
00000000: 7f45 4c46 0201 0100 0000 0000 0000 0000  .ELF............
00000010: 0100 3e00 0100 0000 0000 0000 0000 0000  ..>.............
00000020: 0000 0000 0000 0000 4000 0000 0000 0000  ........@.......
00000030: 0000 0000 4000 0000 0000 4000 0700 0300  ....@.....@.....
00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
...
```


Alternatively, you can use `objdump` to see machine code alongside assembly instructions:

```sh
objdump -d hello
```

```
hello:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <_start>:
  401000:       b8 01 00 00 00          mov    $0x1,%eax
  401005:       bf 01 00 00 00          mov    $0x1,%edi
  40100a:       48 be 00 20 40 00 00    movabs $0x402000,%rsi
  401011:       00 00 00 
  401014:       ba 0e 00 00 00          mov    $0xe,%edx
  401019:       0f 05                   syscall 
  40101b:       b8 3c 00 00 00          mov    $0x3c,%eax
  401020:       bf 00 00 00 00          mov    $0x0,%edi
  401025:       0f 05                   syscall 
```

### Scripts

- [`run.sh`](./run.sh): Interactive script to compile, link, and run any `.asm` file.
- [`library/run_tests.sh`](./library/run_tests.sh): Script to compile, link, and run all library tests.

### Library

The [`library/`](./library) folder contains reusable assembly code. Every time I write assembly I feel like I'm reinventing C and it's standard library from first principles. It's included into programs using NASM's `%include` directive.

| File                                                                                            | Description                                                                                                        |
| ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [`syscalls.asm`](./library/syscalls.asm)                                                        | System call wrappers (`WRITE`, `READ`, `PRINT`, `EXIT` macros) and constants (syscall numbers, file descriptors)   |
| [`strutils.asm`](./library/strutils.asm)                                                        | String utilities: `strlen`, `strcmp`, `itoa`, `atoi`, `strcpy`, `strcat`, `strfindchar`, base conversion, and more |
| [`stdio.asm`](./library/stdio.asm)                                                              | I/O functions: `print_str`, `read_str`, `print_int`; builds on top of `syscalls.asm` and `strutils.asm`            |
| [`bool.asm`](./library/bool.asm)                                                                | Boolean constants (`TRUE`, `FALSE`) and conversions (`bool_to_str`, `str_to_bool`)                                 |
| [`test-assert.asm`](./library/test-assert.asm)                                                  | Unit test framework with `ASSERT_EQ`/`NE`/`LT`/`LE`/`GT`/`GE`/`TRUE`/`FALSE`/`STR_EQ` macros                       |
| [`bool.test.asm`](./library/bool.test.asm) / [`strutils.test.asm`](./library/strutils.test.asm) | Test files for library modules                                                                                     |
| [`TESTING.md`](./library/TESTING.md)                                                            | Test framework documentation                                                                                       |

### Debugging

A GDB quick reference cheatsheet can be found at [`GDB.md`](./GDB.md).

---

## System Architecture

Different architectures need different assembly as they have different registers and syscalls.

>[!TIP]
> To check the system architecture use the `uname -m` or `arch` command.
> - `x86-64` or `AMD64` or `Intel 64`: 64-bit Intel/AMD (this repository assumes this architecture)
> - `i686` or `i386`: 32-bit Intel/AMD
> - `aarch64` or `arm64`: 64-bit ARM
> - `arm7l`: 32-bit ARM
> - etc.
>
> On Windows, use `systeminfo | findstr /C:"System Type"` or simply `echo $Env:PROCESSOR_ARCHITECTURE`.

### `x86`

`x86` is a family of _instruction set architectures (ISAs)_ based on the _Intel 8086 processor_ from 1978. It's called "x86" because Intel's processors were named "8086", "80186", "80286" etc.; notice the "86" pattern. 

#### `8086` (1978): The Beginning

- 16-bit processor
- Addressable RAM: 1MB
- Registers: `AX`, `BX`, `CX`, `DX`, `SI`, `DI`, `BP`, `SP`
- Used in the original IBM PC

#### `80286` (1982)

- Still 16-bit, but with "protected mode"
- Addressable RAM: 16MB
- IBM PC/AT

#### `80386` (1986): The 32-bit Revolution

- 32-bit Registers: `EAX`, `EBX`, `ECX`, `EDX` etc.
- Addressable RAM: 4GB
- This is often called **IA-32** (Intel Architecture, 32-bit) or just **x86**

#### `80486`, Pentium, Pentium II, III, 4... (1989-2000s)

- Still 32-bit, but faster with more features
- Added `MMX`, `SSE`, `SSE2` (`SIMD` instruction for multimedia)

#### `AMD64` / `x86-64` (2003) - The 64-bit Extension

- AMD (not Intel) created the 64-bit extension
- 64-bit Registers: `RAX`, `RBX`, `RCX`, `RDX` etc.
- Can address 256TB of RAM (theoretically, way more)
- Intel adopted it (calling it Intel 64)
- Backwards Compatible: You can use `AL` (lower 8 bits), `AH` (upper 8 bits fo lower 16), `AX` (lower 16 bits), `EAX` (lower 32 bits), `RAX` (full 64 bits)
- We are here

#### Why Does x86 Dominate the PC?

1. **Backward Compatibility**: Every new x86 CPU can run ancient 8086 code from 1978!
2. **Massive Software Ecosystem**: Windows, Linux, Most Desktop Apps
3. **Intel and AMD Competition**: Drove performance improvements
4. **Network Effects**: Everyone uses it, so everyone develops for it and the cycle repeats

### `ARM`

ARM is a **RISC** (Reduced Instruction Set Computer) architecture. Unlike x86's CISC approach (where individual instructions can be complex and multi-cycle) ARM keeps its instructions simple, uniform in size, and generally executes in a single cycle. This trade-off means ARM needs more instructions to do the same work, but each instruction runs faster and uses less power.

The RISC vs CISC divide defined CPU design from the 1980s onward. x86 went CISC for backward compatibility and density; ARM went RISC for simplicity and efficiency.

#### ARM Generations

| Architecture       | Notable Cores              | Key Changes                                                  |
| ------------------ | -------------------------- | ------------------------------------------------------------ |
| **ARMv7** (2011)   | Cortex-A8, A9, A15         | 32-bit, used in early smartphones                            |
| **ARMv8-A** (2014) | Cortex-A53, A72, Apple A7+ | Added 64-bit (`aarch64`), Apple's first custom ARM chip (A7) |
| **ARMv9** (2021)   | Cortex-X2, A510, A710      | Focus on security (CCA), DSP, and ML performance             |

#### Arms

| Architecture | Typical Devices                                           |
| ------------ | --------------------------------------------------------- |
| **Cortex-M** | Microcontrollers, IoT, Arduino-style boards               |
| **Cortex-R** | Real-time: automotive, medical devices                    |
| **Cortex-A** | Application: smartphones, tablets, servers, Apple Silicon |

**Where ARM dominates:**
- Smartphones and Tablets: virtually every mobile device
- Apple Silicon (M1, M2, M3, M4), transitioning from x86
- Servers: AWS Graviton, Ampere, Microsoft Azure Cobalt
- Embedded Systems: routers, IoT, microcontrollers
- Raspberry Pi: educational and hobbyist computing

ARM's efficiency advantage is why it's gaining ground in laptops and servers, exactly the space x86 has owned for decades.

---

## Registers

Registers are small, extremely fast storage locations built directly into the CPU. They can be thought of as the CPU's working memory. Accessing the registers is super fast (~1 CPU cycle i.e. 0.3 nanoseconds on a 3GHz CPU) when compared to L1 (~4 cycles), L2 (~12 cycles), RAM (~200 cycles), or SSD (~millions of cycles). **Registers are 100-1000x faster than RAM**.

The CPU loads data from the RAM into registers, performs the operations on the registers, then stores the results back to RAM.

```
16-bit: | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
32-bit: | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
64-bit: | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
```

- `x86` has 8 general-purpose 32-bit registers: `EAX`, `EBX`, `ECX`, `EDX`, `ESI`, `EDI`, `EBP`, `ESP`
- `x86-64` has 16 general-purpose 64-bit registers: `RAX`, `RBX`, `RCX`, `RDX`, `RSI`, `RDI`, `RBP`, `RSP`, `R8` - `R15`

### Complete `x86-64` Register List

```
64-bit    32-bit   16-bit   8-bit(high)  8-bit(low)
┌───────────────────────────────────────────────────┐
│ RAX      EAX      AX       AH           AL        │  Accumulator
│ RBX      EBX      BX       BH           BL        │  Base
│ RCX      ECX      CX       CH           CL        │  Counter
│ RDX      EDX      DX       DH           DL        │  Data
│ RSI      ESI      SI       -            SIL       │  Source Index
│ RDI      EDI      DI       -            DIL       │  Destination Index
│ RBP      EBP      BP       -            BPL       │  Base Pointer
│ RSP      ESP      SP       -            SPL       │  Stack Pointer
│ R8       R8D      R8W      -            R8B       │  General Purpose
│ R9       R9D      R9W      -            R9B       │  General Purpose
│ R10      R10D     R10W     -            R10B      │  General Purpose
│ R11      R11D     R11W     -            R11B      │  General Purpose
│ R12      R12D     R12W     -            R12B      │  General Purpose
│ R13      R13D     R13W     -            R13B      │  General Purpose
│ R14      R14D     R14W     -            R14B      │  General Purpose
│ R15      R15D     R15W     -            R15B      │  General Purpose
└───────────────────────────────────────────────────┘
```

While you _can_ use any general-purpose register for anything, there are some traditional conventions:
- `RAX`: Accumulator (math operations, return values)
- `RBX`: Base Register (Base pointer for memory access)
- `RCX`: Counter (Loop counters, Shift counts)
- `RDX`: Data (I/O operations, with RAX for large multiplication/division)
- `RSI`: Source Index (string/memory operations source)
- `RDI`: Destination Index (string/memory operations destination)
- `RBP`: Base Pointer (Stack Frame Base)
- `RSP`: Stack Pointer (Top of Stack). **Don't touch it. Stack will break!**

## Programs

### The Anatomy of a Program

A standard assembly program is divided into distinct sections:
- `section .data`: This section is used for declaring initialized data or constants. It is where you define variables and their initial values.
- `section .bss`: This section is used for declaring variables that are not initialized. (e.g. a buffer to store user input at runtime)
- `section .text`: This section contains the actual code (instructions) that the CPU will execute. It is where you write the logic of your program.

### The ELF Binary Format

When `nasm` and `ld` finish their work, the result is an **ELF** (Executable and Linkable Format) binary; the standard executable format on Linux. Every ELF file starts with the magic bytes `7f 45 4c 46` (`.ELF` in ASCII).

The layout of a linked ELF executable looks roughly like this:

```
+----------------------------+
| ELF Header (64 bytes)      |  <- starts with 7f 45 4c 46
+----------------------------+
| Program Headers            |  <- tells the kernel what to load and where
| (aka segment table)        |
+----------------------------+
| .text section              |  <- your code (read + execute)
+----------------------------+
| .rodata / .data section    |  <- constants and initialized data (read + write)
+----------------------------+
| .bss (not in file,         |  <- zero-initialized data, allocated at load time
|      allocated at runtime) |
+----------------------------+
| Section Header Table       |  <- used by linkers and debuggers, not needed at runtime
+----------------------------+
```

An ELF has two structural views, serving different stages of the program's life:

**At link time** the linker works with **sections** (`.text`, `.data`, `.bss`, debug strings, etc.). These organize the content within object files so the linker can merge them. Inspect with `readelf -S <binary>`.

**At load time** the kernel uses **segments** (a.k.a. program headers) to decide what to map into memory, with what permissions, and at what address. Each segment is one or more sections grouped by permission. For example, `.text` and `.rodata` often go into a single read-only segment; `.data` and `.bss` go into a read-write segment. Inspect with `readelf -l <binary>`.

The `xxd` hexdump of the ELF header:

```
00000000: 7f45 4c46 0201 0100 0000 0000 0000 0000  .ELF............
```

The first 16 bytes break down as:

| Offset    | Bytes      | Meaning                               |
| --------- | ---------- | ------------------------------------- |
| 0x00      | `7f`       | ELF magic byte 0                      |
| 0x01      | `45 4c 46` | `E` `L` `F` in ASCII                  |
| 0x04      | `02`       | 64-bit format (1 = 32-bit)            |
| 0x05      | `01`       | Little-endian (2 = big-endian)        |
| 0x06      | `01`       | ELF version                           |
| 0x07      | `00`       | OS/ABI (0 = System V, no special ABI) |
| 0x08-0x0f | `00...`    | Padding bytes                         |

The first two bytes `0x7f` then `ELF` are the universal signature that identifies any ELF file. The `02` tells you it is 64-bit, `01` tells you it is little-endian (which x86-64 always is).

### Linux Syscalls

Assembly can't print to the screen or read a file on its own; It has to ask the operating-system (linux) to do it. This is done using **syscalls** (system calls). A syscall is a request to the kernel to perform a specific operation on behalf of the program. Each syscall has a unique number and may require specific arguments.

To make a syscall in `x86-64` assembly, you typically:
1. Place the syscall number in the `RAX` register.
2. Place the arguments in the appropriate registers:
   - `RDI`: 1st argument
   - `RSI`: 2nd argument
   - `RDX`: 3rd argument
3. Execute the `syscall` instruction to hand control to the Linux kernel.

### Calling Conventions (System V ABI)

When calling your own functions (or interfacing with C), the **System V AMD64 ABI** is the standard on Linux. The library functions in this repo follow this convention.

**Argument passing**: first 6 integer/pointer args go in registers; the rest go on the stack (right-to-left):

```
Arg 1:  RDI
Arg 2:  RSI
Arg 3:  RDX
Arg 4:  RCX
Arg 5:  R8
Arg 6:  R9
Arg 7+: stack
```

**Return value:** `RAX` (or `RDX:RAX` for 128-bit values).

**Register preservation:**

| Preserved by callee | Scratch (caller-saved)   |
| ------------------- | ------------------------ |
| `RBX`, `RBP`, `RSP` | `RAX`, `RCX`, `RDX`      |
| `R12`–`R15`         | `RSI`, `RDI`, `R8`–`R11` |

- Callee-saved registers must be restored before returning.
- Scratch registers may be clobbered by any function call; save them first if you need the values later.

> [!CAUTION]
> Windows uses a different calling convention (Microsoft x64), because of course it does. If you trying to write cross-platform assembly, you'll need to account for these differences; and good luck.

---

## 📕 References

### 📄 Manuals

- [NASM: The Netwide Assembler](https://www.nasm.us/)
- [NASM: Docs](https://www.nasm.us/docs/3.01/)
- [Chromium Linux Syscalls Table](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#x86_64-64-bit)
- [Linux Syscalls Table](https://lxr.linux.no/linux+v3.2/arch/x86/include/asm/unistd_64.h)

### 🖥️ Emulators

- [CPULator: Emulator](https://cpulator.01xz.net/)

### 🌐 Articles and Blogs

- [Building a Web Server in Assembly - fr4nkFletcher.github.io](https://fr4nkfletcher.github.io/posts/Building_a_webserver_in_Assembly/#:~:text=In%20this%20post%2C%20we%20will%20explore%20how%20to,dive%20deep%20into%20how%20low-level%20socket%20programming%20works.)

### 📽️ Videos

- [Assembly Language in 100 seconds - Fireship YouTube](https://www.youtube.com/watch?v=4gwYkEK0gOk)
- [Assembly Language & Computer Architecture - MIT OCW YouTube](https://www.youtube.com/watch?v=L1ung0wil9Y)
- [Machine Code Explained - Computerphile YouTube](https://www.youtube.com/watch?v=8VsiYWW9r48)
- [Hello Assembly! Retrocoding the smallest Windows App in x86 - Dave's Garage YouTube](https://www.youtube.com/watch?v=b0zxIfJJLAY)
- [Forget C Assembly is all you need - Tsoding YouTube](https://www.youtube.com/watch?v=hzjBdIJ9Ycs)
- [Web in Native Assembly - Tsoding YouTube](https://www.youtube.com/watch?v=b-q4QBy52AA)
- [To-Do App in Assembly - Tsoding YouTube](https://www.youtube.com/watch?v=WnBXLmKk_qw)
- [Assembly Language Programming with ARM - freeCodeCamp YouTube](https://www.youtube.com/watch?v=gfmRrPjnEw4)
- [Practical ARM Assembly Tutorial - LaurieWired YouTube](https://www.youtube.com/playlist?list=PLn_It163He32Ujm-l_czgEBhbJjOUgFhg)
- [You can learn assembly in 10 minutes - Low Level YouTube](https://www.youtube.com/watch?v=6S5KRJv-7RU)
- [You can learn ARM assembly in 15 minutes - Low Level YouTube](https://www.youtube.com/watch?v=FV6P5eRmMh8)

---

## 📄 License

This repository is licensed under the [MIT License](./LICENSE).
