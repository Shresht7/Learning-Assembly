# GDB

## Quick Reference

```bash
# Starting
gdb ./program               # Start GDB
gdb --args ./prog arg1      # Start with arguments

# Breakpoints
break _start                # Break at label
break *0x401000             # Break at address
break file.asm:10           # Break at line
delete 1                    # Delete breakpoint 1
info breakpoints            # List all breakpoints

# Running
run                         # Start program
continue                    # Continue execution
stepi                       # Execute one instruction
nexti                       # Next instruction (skip calls)
finish                      # Run until function returns

# Examining
info registers              # Show all registers
print $rax                  # Print RAX register
print/x $rax                # Print RAX register in hexadecimal
x/10i $rip                  # Show next 10 instructions
x/5dg 0x402000              # Show 5 quad-words at address
display $rax                # Auto-display after each step

# Memory
x/s address                 # View as string
x/10xb address              # View 10 bytes in hexadecimal
x/i address                 # View as instruction
set $rax = 100              # Modify register
set {long}0x402000 = 99     # Modify memory

# Other
backtrace                   # Show call stack
info frame                  # Show current stack frame
layout asm                  # Show assembly in TUI mode
layout regs                 # Show registers in TUI mode
quit                        # Exit GDB
```

---

## Display Formats

### Decimal

```gdb
(gdb) print $rax
$1 = 150
```

### Hexadecimal

```gdb
(gdb) print/x $rax
$2 = 0x96
```

### Binary

```gdb
(gdb) print/t $rax
$3 = 10010110
```

### Character

```gdb
(gdb) print/c $rax
$4 = 150 '\226'
```

## Memory Examination

`x/[count][format][size]` address

- `format`: `x=hex`, `d=decimal`, `s=string`, `i=instruction`
- `size`: `b=byte`, `h=halfword(2)`, `w=word(4)`, `g=giant(8)`

### Show 5 quad-words in decimal

```gdb
(gdb) x/5dg 0x402000
0x402000:   10  20
0x402010:   30  40
0x402020:   50
```

### Show as hex

```gdb
(gdb) x/5xg 0x402000
0x402000:   0x000000000000000a  0x00000000000000014
0x402010:   0x000000000000001e  0x00000000000000028
0x402020:   0x0000000000000032
```

### Show next 10 instructions

```gdb
(gdb) x/10i $rip
=>  0x401000 <_start>:      mov     rdi, 0x402000
    0x401007 <_start+7>     mov     rsi, 0x5
    ox40100e <_start+14>:   call    0x401050 <calculate_sum> 
```

### Show string

```(gdb)
(gdb) x/s 0x402000
0x402000:   "\n"
```

## Watchpoints (Break on Memory Change)

### Break when sum variable changes

```gdb
(gdb) watch sum
Harware watchpoint 2: sum

# Run until sum is modified
(gdb) continue
Hardware watchpoint 2: sum
Old value = 0
New value = 150
```

## Conditional Breakpoints

```gdb
# Break only when RCX equals 3
(gdb) break calculate_sum.loop if $rcx == 3

# Break when array element > 30
(gdb) break *0x401060 if *(long*)($rdi + $rcx*8) > 30
```

## Display Values Automatically

```gdb
# Show RAX after every step
(gdb) display/x $rax
1: /x $rax = 0x0

# Show memory contents
(gdb) display/x *(long*)($rdi + $rci*8)
2: /x *(long*)($rdi + $rcx*8) = 0xa

# Now every stepi shows these automatically
(gdb) stepi
1: /x $rax = 0xa
2: /x *(long*)($rdi + $rcx*8) = 0x14
```
