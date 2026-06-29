[org 0x8000]
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
    ; 5. [32비트 C언어 스타일 테스트] 비디오 메모리에 직접 사각형 그리기
    ; 5. [32-bit C-style Test] Draw a rectangle directly to Video Memory
    ; ----------------------------------------------------
    ; BIOS를 못 쓰므로 그래픽 모드(VRAM) 주소인 0xA0000에 포인터처럼 직접 데이터를 씁니다.
    ; Since BIOS is unavailable, write data directly to 0xA0000 (VRAM address) like a pointer.
    
    mov edi, 0xA0000    ; 비디오 메모리 시작 물리 주소
                        ; Video memory starting physical address

    ; 가로 100, 세로 50 위치 계산: (50 * 320) + 100 = 16100
    ; Calculate position for X=100, Y=50: (50 * 320) + 100 = 16100
    add edi, 16100

    mov edx, 0          ; Y 루프 카운터 (세로 30줄)
                        ; Y loop counter (30 rows)

draw_32bit_row:
    mov ecx, 0          ; X 루프 카운터 (가로 50칸)
                        ; X loop counter (50 columns)

draw_32bit_col:
    mov byte [edi], 12  ; 색상 번호 대입 (12 = 빨간색)
                        ; Assign color number (12 = Red)
    inc edi             ; 다음 픽셀 주소로 이동
                        ; Move to the next pixel address
    inc ecx
    cmp ecx, 50
    jl draw_32bit_col

    ; 가로 한 줄을 다 그렸으면, 다음 줄의 시작점으로 EDI 포인터 건너뛰기
    ; After drawing one row, skip EDI pointer to the start of the next row
    ; 한 줄이 320픽셀인데 방금 50픽셀을 전진했으므로, 남은 270픽셀만큼 더해줍니다.
    ; Since a single line is 320 pixels and we have just advanced 50 pixels, we add the remaining 270 pixels.
    add edi, 270
    
    inc edx
    cmp edx, 30
    jl draw_32bit_row

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
times 512 - ($ - $$) db 0
