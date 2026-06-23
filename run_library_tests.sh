#!/bin/env sh

# Compile and run the tests for the library

LIB="src/library/"
OBJ="obj/"
OUT="out/"

# Compile the test assembly file into an object file
nasm -f elf64 $LIB/strutils.test.asm -o $OBJ/strutils.test.o

# Link the object file to create an executable
ld $OBJ/strutils.test.o -o $OUT/strutils.test

# Run the executable
$OUT/strutils.test
