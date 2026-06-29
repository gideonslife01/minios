[org 0x7c00]
bits 16

start:
    ; 데이터 세그먼트 레지스터 초기화
    ; Initialize data segment registers
    mov ax, 0
    mov ds, ax
    mov es, ax

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

    ; 디스크 읽기 (2번 섹터부터 1개 섹터를 0x8000에 로드)
    ; Disk read (Load 1 sector from sector 2 into memory 0x8000)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, 0x8000
    int 0x13

    ; 디스크 읽기 실패 시 에러 처리
    ; Error handling if disk read fails
    jc disk_error

    ; 로드된 2번 섹터 코드로 점프하여 실행
    ; Jump to the loaded sector 2 code and execute
    ; jmp 0x8000
    jmp 0x0000:0x8000

disk_error:
    ; 에러 발생 시 시스템 멈춤 (그래픽 모드이므로 텍스트 출력은 일단 생략)
    ; System hang on error (Text print is omitted for now since it is in graphic mode)
    jmp hang

hang:
    jmp $

; 1번 섹터(MBR) 빈 공간을 0으로 채우고 부트 시그니처 추가
; Fill remaining space of sector 1 (MBR) with 0 and add boot signature
times 510 - ($ - $$) db 0
dw 0xaa55
