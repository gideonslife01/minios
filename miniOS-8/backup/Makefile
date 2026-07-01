# ----------------------------------------------------
# 컴파일러 및 빌드 도구 정의
# Define compilers and build tools
# ----------------------------------------------------
NASM = nasm
CC = gcc
LD = ld

# ----------------------------------------------------
# C 컴파일러 플래그 설정 (32비트 보호모드 전용 독립형 옵션)
# C Compiler Flags (Freestanding options for 32-bit protected mode)
# ----------------------------------------------------
CFLAGS = -m32 -ffreestanding -fno-pie -nostdlib -fno-stack-protector -c

# ----------------------------------------------------
# 기본 빌드 타겟 설정
# Default build target
# ----------------------------------------------------
all: os_image.bin

# ----------------------------------------------------
# 1단계: 제1섹터 부트로더 빌드 (순수 바이너리)
# Step 1: Build Sector 1 Bootloader (Pure Binary)
# ----------------------------------------------------
boot.bin: boot.asm
	$(NASM) -f bin boot.asm -o boot.bin

# ----------------------------------------------------
# 2단계: 제2섹터 보호모드 진입 어셈블리 오브젝트 파일 생성
# Step 2: Generate Sector 2 Protected Mode Assembly Object File
# ----------------------------------------------------
sector2.o: sector2.asm
	$(NASM) -f elf32 sector2.asm -o sector2.o

# ----------------------------------------------------
# 3단계: C언어 커널 소스코드(kernel.c) 오브젝트 파일 생성
# Step 3: Generate C Language Kernel Object File (kernel.c)
# ----------------------------------------------------
kernel.o: kernel.c
	$(CC) $(CFLAGS) kernel.c -o kernel.o

# ----------------------------------------------------
# 4단계: 링커 스크립트를 사용하여 0x8000 기준으로 커널 바이너리 병합
# Step 4: Link sector2.o and kernel.o based on 0x8000 using linker script
# ----------------------------------------------------
kernel.bin: sector2.o kernel.o linker.ld
	$(LD) -m elf_i386 -T linker.ld sector2.o kernel.o -o kernel.bin

# ----------------------------------------------------
# 5단계: 부트 섹터와 커널 섹터를 하나로 합쳐 최종 OS 이미지 파일 생성
# Step 5: Combine boot sector and kernel sector to create final OS image file
# ----------------------------------------------------
os_image.bin: boot.bin kernel.bin
	cat boot.bin kernel.bin > os_image.bin

# ----------------------------------------------------
# 실행 규칙: QEMU를 이용해 os_image.bin 실행
# Run Rule: Execute os_image.bin using QEMU
# ----------------------------------------------------
run: os_image.bin
	qemu-system-i386 -drive format=raw,file=os_image.bin

# ----------------------------------------------------
# 정리 규칙: 빌드 도중 생성된 부산물 삭제
# Clean Rule: Delete temporary files generated during build
# ----------------------------------------------------
clean:
	rm -f *.bin *.o
