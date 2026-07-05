#!/bin/env sh

# Compile and run the tests for the library
# $ ./library/run_tests.sh

# Various directories, resolved relative to the root of the project
LIB="library/"
OBJ="obj/"
OUT="out/"

# Create the output directory if it doesn't exist
mkdir -p $OUT
mkdir -p $OBJ

# Get all .test.asm files in the library directory
TEST_FILES=$(find $LIB -name "*.test.asm")

# Function to compile and run a single test file
compile_and_run_test() {
    local TEST_FILE=$1
    local TEST_NAME=$(basename $TEST_FILE .test.asm)

    # Compile the test assembly file into an object file
    nasm -f elf64 $TEST_FILE -o $OBJ/$TEST_NAME.test.o

    # Link the object file to create an executable
    ld $OBJ/$TEST_NAME.test.o -o $OUT/$TEST_NAME.test

    # Run the executable
    $OUT/$TEST_NAME.test
}

# Loop through each test file and compile and run it
for TEST_FILE in $TEST_FILES; do
    compile_and_run_test $TEST_FILE
    $OUT/$TEST_NAME.test
done
