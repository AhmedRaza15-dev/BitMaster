#!/bin/bash
echo "Building BitMaster..."
nasm -f elf32 bitmaster.asm -o bitmaster.o
ld -m elf_i386 bitmaster.o -o bitmaster
echo "Build complete! Run with: ./bitmaster"

