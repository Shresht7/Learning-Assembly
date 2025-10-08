# Learning Assembly

Assembly is the lowest-level human-readable programming language. It maps directly to machine code - the binary instructions that the CPU executes. Each assembly instruction typically corresponds to one CPU operation.

---

## System Architecture

Different architectures need different assembly as they have different registers and syscalls.

>![TIP]
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

- 32-bit Registers: `EAX`, `EBX`, `ECX`, `RDX` etc.
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

TODO: List out all Registers in x86-64
TODO: Syscall table
TODO: CISC vs RISC. Explain RISC
