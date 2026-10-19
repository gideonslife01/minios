[org 0x7c00]
bits 16

start:
    ; 데이터 세그먼트 레지스터 초기화
    ; Initialize data segment registers
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; ----------------------------------------------------
    ; 표준 80x25 텍스트 모드(Mode 3)로 전환
    ; Switch to standard 80x25 text mode (Mode 3)
    ; ----------------------------------------------------
    mov ah, 0x00        ; 화면 모드 설정 기능 / Screen mode setting feature
    mov al, 0x03        ; 텍스트 모드 번호 / Text mode number
    int 0x10            ; 비디오 인터럽트 호출 / Video interrupt call

    ; ----------------------------------------------------
    ; 디스크 읽기 (2번 섹터부터 12개 섹터를 0x8000에 로드)
    ; Disk read (load 12 sectors, starting from sector 2, into 0x8000)
    ; ----------------------------------------------------
    mov ah, 0x02        ; 디스크 읽기 기능 / Disk reading capability
    mov al, 12          ; 읽어올 섹터 개수(12개) / Number of sectors to read (12)
    mov ch, 0           ; 실린더 0 / Cylinder 0
    mov cl, 2           ; 시작 섹터 2 / Starting sector 2
    mov dh, 0           ; 헤드 0 / Head 0
    mov bx, 0x8000      ; 메모리 0x8000에 로드 / Loaded into memory 0x8000
    int 0x13

    ; 디스크 읽기 실패 시 에러 처리 / Error handling for disk read failures
    jc disk_error

    ; 로드된 2번 섹터 코드로 점프 / Jump to loaded sector 2 code
    jmp 0x0000:0x8000

disk_error:
    jmp hang

hang:
    jmp $

; MBR 부트 시그니처 (512바이트 맞춤) / MBR boot signature (512-byte aligned)
times 510 - ($ - $$) db 0
dw 0xaa55