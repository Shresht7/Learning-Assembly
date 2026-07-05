# Learning Assembly

Assembly is the lowest-level human-readable programming language. It maps directly to machine code - the binary instructions that the CPU executes. Each assembly instruction typically corresponds to one CPU operation.

---

## Repository

### Requirements

You need an **assembler** to turn your text into machine code, and a linker to turn that machine code into an executable file.

- `nasm`: The Netwide Assembler, a popular assembler for x86 architecture. Uses Intel syntax, which is generally considered easier to read.
- `ld`: The GNU linker, which combines object files into a single executable.

Nice to have:

- `gdb`: The GNU Debugger, a powerful tool for debugging programs. It allows you to inspect the state of a program while it's running or after it crashes.
- `make`: A build automation tool that automatically builds executable programs and libraries from source code by reading files called Makefiles.

```sh
sudo dnf install nasm binutils gdb make
```

### To compile the `.asm` files

```sh
nasm -f elf64 ./src/hello.asm -o ./obj/hello.o
```

### To link the object files into an executable

```sh
ld ./obj/hello.o -o ./out/hello
```

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

`x86` is a family of _instruction set architectures (ISAs)_ based on the _Intel 8086 processor_ from 1978. It's called "x86" because Intel's processors were named "8086", "80186", "80286" etc. - notice the "86" pattern. 

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

#### Why x86 Dominate PC?

1. **Backward Compatibility**: Every new x86 CPU can run ancient 8086 code from 1978!
2. **Massive Software Ecosystem**: Windows, Linux, Most Desktop Apps
3. **Intel and AMD Competition**: Drove performance improvements
4. **Network Effects**: Everyone uses it, so everyone develops for it and the cycle repeats

### `ARM`

ARM (a RISC architecture) is dominant in:
- Smartphones (every iPhone, Android)
- Tablets
- Apple Silicon Macs (M1, M2, M3)
- Servers (AWS Graviton)
- Embedded Systems

ARM is simpler and more power-efficient.

---

## Registers

Registers are small, extremely fast storage locations built directly into the CPU. They can be though of as the CPU's working memory. Accessing the registers is super fast (~1 CPU cycle i.e. 0.3 nanoseconds on a 3GHz CPU) when compared to L1 (~4 cycles), L2 (~12 cycles), RAM (~200 cycles), or SSD (~millions of cycles). **Registers are 100-1000x faster than RAM**.

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

### Linux Syscalls

Assembly can't print to the screen or read a file on its own; It has to ask the operating-system (linux) to do it. This is done using **syscalls** (system calls). A syscall is a request to the kernel to perform a specific operation on behalf of the program. Each syscall has a unique number and may require specific arguments.

To make a syscall in `x86-64` assembly, you typically:
1. Place the syscall number in the `RAX` register.
2. Place the arguments in the appropriate registers:
   - `RDI`: 1st argument
   - `RSI`: 2nd argument
   - `RDX`: 3rd argument
3. Execute the `syscall` instruction to hand control to the Linux kernel.

---

## 📕 References

- [NASM: The Netwide Assembler](https://www.nasm.us/)
- [NASM: Docs](https://www.nasm.us/docs/3.01/)

### 📄 Manuals

- 📄 [Chromium Linux Syscalls Table](https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#x86_64-64-bit)
- 📄 [Linux Syscalls Table](https://lxr.linux.no/linux+v3.2/arch/x86/include/asm/unistd_64.h)

### 🖥️ Emulators

- 🖥️ [CPULator: Emulator](https://cpulator.01xz.net/)

### 🌐 Articles and Blogs

- 📄 [Building a Web Server in Assembly - fr4nkFletcher.github.io](https://fr4nkfletcher.github.io/posts/Building_a_webserver_in_Assembly/#:~:text=In%20this%20post%2C%20we%20will%20explore%20how%20to,dive%20deep%20into%20how%20low-level%20socket%20programming%20works.)

### 📽️ Videos

- 📽️ [Assembly Language in 100 seconds - Fireship YouTube](https://www.youtube.com/watch?v=4gwYkEK0gOk)
- 📽️ [Assembly Language & Computer Architecture - MIT OCW YouTube](https://www.youtube.com/watch?v=L1ung0wil9Y)
- 📽️ [Machine Code Explained - Computerphile YouTube](https://www.youtube.com/watch?v=8VsiYWW9r48)
- 📽️ [Hello Assembly! Retrocoding the smallest Windows App in x86 - Dave's Garage YouTube](https://www.youtube.com/watch?v=b0zxIfJJLAY)
- 📽️ [Forget C Assembly is all you need - Tsoding YouTube](https://www.youtube.com/watch?v=hzjBdIJ9Ycs)
- 📽️ [Web in Native Assembly - Tsoding YouTube](https://www.youtube.com/watch?v=b-q4QBy52AA)
- 📽️ [To-Do App in Assembly - Tsoding YouTube](https://www.youtube.com/watch?v=WnBXLmKk_qw)
- 📽️ [Assembly Language Programming with ARM - freeCodeCamp YouTube](https://www.youtube.com/watch?v=gfmRrPjnEw4)
- 📽️ [Practical ARM Assembly Tutorial - LaurieWired YouTube](https://www.youtube.com/playlist?list=PLn_It163He32Ujm-l_czgEBhbJjOUgFhg)
- 📽️ [You can learn assembly in 10 minutes - Low Level YouTube](https://www.youtube.com/watch?v=6S5KRJv-7RU)
- 📽️ [You can learn ARM assembly in 15 minutes - Low Level YouTube](https://www.youtube.com/watch?v=FV6P5eRmMh8)

---

## 📄 License

This repository is licensed under the [MIT License](./LICENSE).
