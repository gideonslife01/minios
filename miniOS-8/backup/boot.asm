[org 0x7c00]
bits 16

start:
    ; ----------------------------------------------------
    ; 세그먼트 및 스택 레지스터 초기화
    ; Initialize segment and stack registers
    ; ----------------------------------------------------
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax          ; 스택 세그먼트를 0으로 설정
                        ; Set Stack Segment to 0
    mov sp, 0x7C00      ; 스택 포인터를 부트로더 직전 주소로 설정 (안전 영역)
                        ; Set Stack Pointer right below the bootloader (Safe zone)

    ; ----------------------------------------------------
    ; BIOS 인터럽트를 이용해 320x200 256색 그래픽 모드로 전환
    ; Switch to 320x200 256-color graphic mode using BIOS interrupt
    ; ----------------------------------------------------
    mov ah, 0x00        ; 화면 모드 설정 기능 선택
                        ; Select screen mode set function
    mov al, 0x13        ; 320x200 256색 그래픽 모드 번호 (Mode 13h)
                        ; 320x200 256-color graphic mode number (Mode 13h)
    int 0x10            ; 비디오 인터럽트 호출 -> 화면이 검은색 그래픽 창으로 전환됨
                        ; Call video interrupt -> Screen switches to a black graphic window

    ; ----------------------------------------------------
    ; 디스크 읽기 (2번 섹터부터 커널 영역을 0x8000에 로드)
    ; Disk read (Load kernel sectors from sector 2 into memory 0x8000)
    ; ----------------------------------------------------
    mov ah, 0x02        ; BIOS 디스크 읽기 기능 선택
                        ; Select BIOS disk read function
  
    ; ----------------------------------------------------
    ; ★ CHANGED: C 커널 용량이 커질 것을 대비해 읽을 섹터 수를 4에서 15로 확장
    ; ★ CHANGED: Increased sectors to 15 to prevent truncation as the C kernel grows
    ; ----------------------------------------------------
    mov al, 15          ; 읽을 섹터 수 (15개 섹터 = 약 7.5KB)
                        ; Number of sectors to read (15 sectors = approx 7.5KB)
    mov ch, 0           ; 실린더 번호
                        ; Cylinder number
    mov cl, 2           ; 시작 섹터 번호 (2번 섹터부터)
                        ; Sector number to start reading from (Sector 2)
    mov dh, 0           ; 헤드 번호
                        ; Head number
    mov bx, 0x8000      ; 데이터를 저장할 메모리 시작 주소 (ES:BX = 0x0000:0x8000)
                        ; Target memory address to store data (ES:BX = 0x0000:0x8000)
    int 0x13            ; 디스크 인터럽트 호출
                        ; Call disk interrupt

    ; 디스크 읽기 실패 시 에러 처리
    ; Error handling if disk read fails
    jc disk_error

    ; 로드된 2번 섹터(보호모드+C커널) 코드로 점프하여 실행
    ; Jump to the loaded sector 2 (Protected Mode + C Kernel) code and execute
    jmp 0x0000:0x8000

disk_error:
    ; 에러 발생 시 시스템 멈춤
    ; System hang on error
    jmp hang

hang:
    jmp $

; 1번 섹터(MBR) 빈 공간을 0으로 채우고 부트 시그니처 추가 (정확히 512바이트)
; Fill remaining space of sector 1 (MBR) with 0 and add boot signature (Exactly 512 bytes)
times 510 - ($ - $$) db 0
dw 0xaa55
