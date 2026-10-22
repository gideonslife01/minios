section .text           
global start            
global protected_start  

bits 16

start:
    ; 1. 하드웨어 인터럽트 금지 및 세그먼트 레지스터 0으로 초기화
    ; Disable hardware interrupts and initialize segment registers to 0
    cli                 
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; 2. A20 게이트 활성화 (키보드 컨트롤러 이용한 표준 방식)
    ; nable A20 gate (standard method using the keyboard controller)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; 3. GDT 로드 (0x7C00 부트로더에서 DS=0이므로 gdt_pointer의 오프셋 주소를 그대로 읽음)
    ; Load GDT (Since DS=0 in the 0x7C00 bootloader, the offset address of gdt_pointer is read directly)
    lgdt [gdt_pointer]  

    ; 4. CR0 레지스터를 설정하여 32비트 보호 모드 활성화
    ; Enable 32-bit protected mode by setting the CR0 register
    mov eax, cr0        
    or eax, 0x00000001  
    mov cr0, eax        

    ; 5. 32비트 세그먼트 영역으로 멀리뛰기(Far Jump)
    ; Far Jump to a 32-bit segment area
    jmp 0x08:protected_start


; ====================================================
; 32비트 보호 모드 구역 / 32-bit protected mode zone
; ====================================================
bits 32
extern kernel_main      

protected_start:
    ; 32비트 세그먼트 레지스터 초기화 (GDT 오프셋 0x10)
    ; Initialize 32-bit segment registers (GDT offset 0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000    ; 스택 포인터 설정 / Setting the stack pointer

    ; ----------------------------------------------------
    ; [디버깅 코드] 보호 모드 진입 성공 시 화면 좌측 상단에 'OK' 출력
    ; (만약 C언어가 안 열려도 이 'OK'가 뜨면 보호 모드 진입 성공입니다)
    ; [Debugging Code] Displays 'OK' in the top-left corner of the screen upon successfully entering protected mode
    ; (Even if the C language environment fails to open, 
    ; the appearance of this 'OK' indicates that the system has successfully entered protected mode.)
    ; ----------------------------------------------------
    ;mov byte [ds:0xB8000], 'O'
    ;mov byte [ds:0xB8001], 0x2F  ; 초록 배경, 흰 글자 / Green background, white text
    ;mov byte [ds:0xB8002], 'K'
    ;mov byte [ds:0xB8003], 0x2F

    ; C 커널 메인 함수 호출
    call kernel_main    

.hang:
    hlt
    jmp .hang


; ----------------------------------------------------
; 데이터 영역: GDT(Global Descriptor Table) 구조 정의
; Data Area: Definition of the GDT (Global Descriptor Table) Structure
; ----------------------------------------------------
align 4

gdt_start:
    dd 0, 0             

    ; 코드 세그먼트 (0x08)
    ; Code Segment
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00

    ; 데이터 세그먼트 (0x10)
    ; Data Segment
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start - 1  
    dd gdt_start               