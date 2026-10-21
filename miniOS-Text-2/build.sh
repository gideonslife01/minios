#!/bin/bash

# 1. 기존 빌드 파일 및 이미지 정리
# Clean up existing build files and images
echo "[*] Cleaning old build files..."
rm -f *.bin *.o *.img temp.bin sector2.bin

# 2. 부트로더 컴파일
# Bootloader compilation
echo "[*] Compiling boot.asm..."
nasm -f bin boot.asm -o boot.bin

# 3. 어셈블리 스텁 컴파일 (ELF32)
# Assembly Stub Compilation (ELF32)
echo "[*] Compiling sector2.asm..."
nasm -f elf32 sector2.asm -o sector2.o

# 4. C 커널 컴파일
# C Kernel Compilation
echo "[*] Compiling kernel.c..."
i686-elf-gcc -m32 -c kernel.c -o kernel.o -nostdlib -fno-builtin -fno-stack-protector -fno-pic -fno-PIE

# 5. 링커 실행
# Run linker
echo "[*] Linking objects..."
i686-elf-ld -m elf_i386 -Ttext 0x8000 -e start -o sector2.bin sector2.o kernel.o --oformat binary

# 6. 바이너리 병합 및 디스크 이미지 생성
# Binary Merging and Disk Image Creation
echo "[*] Creating floppy disk image..."
cat boot.bin sector2.bin > temp.bin
dd if=temp.bin of=os.img bs=512 count=2880 conv=sync

# 7. QEMU 실행
# Running QEMU
echo "[*] Running QEMU..."
qemu-system-x86_64 -drive file=os.img,format=raw,if=floppy -boot a -display cocoa
