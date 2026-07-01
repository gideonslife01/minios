; ----------------------------------------------------
; ★ CHANGED: 링커 규격에 맞게 섹션을 선언합니다.
; ★ CHANGED: Declare section instead of [org] for the linker specification.
; ----------------------------------------------------
section .text
bits 16

global start
start:
    ; ----------------------------------------------------
    ; 1. A20 게이트 활성화 (키보드 컨트롤러 이용한 표준 방식)
    ; 1. Enable A20 Gate (Standard method using keyboard controller)
    ; ----------------------------------------------------
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
    jmp 0x08:protected_start


; ====================================================
; 여기서부터는 완전히 32비트 기계어로 실행되는 구역입니다!
; From here, the code executes completely in 32-bit machine code!
; ====================================================
bits 32

extern c_main

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
    ; ★ CHANGED: [스택 설정] C언어 작동을 위한 필수 탑 주소 지정
    ; ★ CHANGED: [Stack Setup] Essential for C language execution, setting top address
    ; ----------------------------------------------------
    mov esp, 0x7000

    ; ----------------------------------------------------
    ; ★ CHANGED: C언어 메인 함수 호출
    ; ★ CHANGED: Call C main function
    ; ----------------------------------------------------
    call c_main

    ; 작업 완료 후 무한 대기
    ; Infinite loop after work completion
    jmp $


; ----------------------------------------------------
; 데이터 영역: GDT(Global Descriptor Table) 구조 정의
; Data Area: Define GDT (Global Descriptor Table) Structure
; ----------------------------------------------------
align 4

gdt_start:
    ; 1. 널 디스크립터
    ; 1. Null Descriptor
    dd 0, 0 

    ; 2. 코드 세그먼트 디스크립터 (오프셋 0x08)
    ; 2. Code Segment Descriptor (Offset 0x08)
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00

    ; 3. 데이터 세그먼트 디스크립터 (오프셋 0x10)
    ; 3. Data Segment Descriptor (Offset 0x10)
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
gdt_end:

; CPU에 GDT 위치를 전달하기 위한 포인터 구조체
; Pointer structure to deliver GDT position to CPU
gdt_pointer:
    dw gdt_end - gdt_start - 1  ; GDT의 크기 (Size of GDT)
    dd gdt_start                ; GDT의 시작 주소 (Starting address of GDT)
