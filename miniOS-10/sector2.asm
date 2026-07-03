; ✅ 코드 제거 / Remove code
;[org 0x8000] 

; ✅ 아래 코드 추가 / Add the code below.
section .text           ;  ELF 포맷 컴파일을 위해 코드 섹션임을 명시합니다.
                        ;  Specifies that it is a code section for ELF format compilation.
global start            ;  링커가 인식할 수 있도록 start 레이블을 외부에 공개합니다.
                        ;  Expose the `start` label so that the linker can recognize it.
global protected_start  ;  멀리뛰기 목적지 레이블도 외부에 공개합니다.
                        ;  We are also making the long-jump destination labels publicly available.

bits 16

start:
    ; --------------------------------────────────────----
    ; 1. A20 게이트 활성화 (키보드 컨트롤러 이용한 표준 방식)
    ; 1. Enable A20 Gate (Standard method using keyboard controller)
    ; --------------------------------────────────────----
    in al, 0x92
    or al, 2
    out 0x92, al

    ; ----------------------------------------------------
    ; 2. GDT(Global Descriptor Table) 정보를 CPU에 로드
    ; 2. Load GDT (Global Descriptor Table) information into CPU
    ; ----------------------------------------------------
    cli                 ; 32비트 전환 중 방해받지 않도록 하드웨어 인터럽트 금지
                        ; Disable hardware interrupts to avoid interruption during 32-bit transition
    lgdt [gdt_pointer]  ; GDT 구조체의 주소를 CPU에 로드
                        ; Load the address of the GDT structure into the CPU

    ; ----------------------------------------------------
    ; 3. CR0 레지스터를 설정하여 32비트 보호 모드 활성화
    ; 3. Set CR0 register to enable 32-bit Protected Mode
    ; ----------------------------------------------------
    mov eax, cr0        ; CR0 레지스터 값을 일반 레지스터로 가져옴
                        ; Load the CR0 register value into a general-purpose register.

    or eax, 0x00000001  ; 0번째 비트(PE: Protection Enable)를 1로 설정
                        ; Set the 0th bit (PE: Protection Enable) to 1.
    mov cr0, eax        ; 변경된 값을 다시 CR0에 적용 (이 순간 32비트 모드 활성화!)
                        ; Apply the modified value back to CR0 (32-bit mode is activated at this moment!)

    ; ----------------------------------------------------
    ; 4. 32비트 세그먼트 영역으로 멀리뛰기(Far Jump)
    ; 4. Far Jump into 32-bit segment region
    ; ----------------------------------------------------
    ; 0x08은 아래 GDT에서 정의한 32비트 코드 세그먼트의 위치(오프셋)입니다.
    ; 0x08 is the offset of the 32-bit code segment defined in the GDT below.
    jmp 0x08:protected_start


; ====================================================
; 여기서부터는 완전히 32비트 기계어로 실행되는 구역입니다!
; From here, the code executes completely in 32-bit machine code!
; ====================================================
bits 32
extern kernel_main      ; ✅ kernel.c의 kernel_main 함수를 참조하도록 수정
                        ; Modified to reference the kernel_main function in kernel.c.

protected_start:
    ; 32비트용 데이터 세그먼트 레지스터들 초기화 (GDT의 0x10 오프셋 사용)
    ; Initialize 32-bit data segment registers (Using 0x10 offset from GDT)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; ----------------------------------------------------
    ; 32비트 스택 포인터 초기화
    ; Initialize 32-bit stack pointer
    ; C언어 변수 및 함수 호출을 위한 스택 영역 지정 (0x90000은 안전한 빈 공간)
    ; Designating the stack area for C language variables and function calls (0x90000 is a safe, empty space)
    ; ----------------------------------------------------
    mov esp, 0x90000

    ; ----------------------------------------------------   
    ; ✅ C언어 커널 메인 함수 호출
    ; C language kernel main function call
    ; C언어로 사각형 그리기 실행 
    ; Executing a program to draw a rectangle in C
    ; ----------------------------------------------------

    call kernel_main    ; ✅ kernel_main으로 점프!
                        ; Jump to kernel_main!

    ; 작업 완료 후 무한 대기
    ; Infinite loop after work completion
    jmp $


; ----------------------------------------------------
; 데이터 영역: GDT(Global Descriptor Table) 구조 정의
; Data Area: Define GDT (Global Descriptor Table) Structure
; ----------------------------------------------------
align 4

gdt_start:
    ; 1. 널 디스크립터 (하드웨어 규격상 필수적인 빈 슬롯)
    ; 1. Null Descriptor (Mandatory empty slot by hardware specification)
    dd 0, 0 

    ; 2. 코드 세그먼트 디스크립터 (오프셋 0x08): 전체 4GB 영역, 읽기/실행 가능
    ; 2. Code Segment Descriptor (Offset 0x08): Full 4GB range, Read/Execute allowed
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00

    ; 3. 데이터 세그먼트 디스크립터 (오프셋 0x10): 전체 4GB 영역, 읽기/쓰기 가능
    ; 3. Data Segment Descriptor (Offset 0x10): Full 4GB range, Read/Write allowed
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
gdt_end:

; CPU에 GDT 위치를 전달하기 위한 포인터 구조체 (6바이트 크기)
; Pointer structure to deliver GDT position to CPU (6 bytes size)
gdt_pointer:
    dw gdt_end - gdt_start - 1  ; GDT의 크기 (Size of GDT)
    dd gdt_start                ; GDT의 시작 주소 (Starting address of GDT)

; 512바이트 크기 맞추기
; Pad to 512 bytes
; times 512 - ($ - $$) db 0
