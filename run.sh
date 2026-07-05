#!/usr/bin/env sh

# Compile, link and run a ASM file

OBJ="obj/"
OUT="out/"

mkdir -p "$OBJ" "$OUT"

# Interactively select an ASM source file if tools are available, otherwise use $1
if command -v fzf >/dev/null 2>&1; then
    if command -v fd >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
        FILE=$(fd -e asm | fzf --preview 'bat --color=always {}' --preview-window 'right:75%')
    else
        FILE=$(find . -name '*.asm' | fzf)
    fi
else
    FILE="$1"
fi

# Check if a file was selected and it exists
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: $0 <file.asm>"
    exit 1
fi

BASENAME=$(basename "$FILE" .asm)

# Compile the selected ASM file to an object file using nasm
nasm -f elf64 "$FILE" -o "$OBJ/${BASENAME}.o"

# Check if the compilation was successful
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Link the object file to create an executable
ld "$OBJ/${BASENAME}.o" -o "$OUT/${BASENAME}"

# Check if the linking was successful
if [ $? -ne 0 ]; then
    echo "Linking failed."
    exit 1
fi

# Run the executable
"$OUT/${BASENAME}"
