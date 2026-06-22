; BIOS가 이 코드를 메모리 0x7C00에 로드합니다.
; The BIOS loads this code into memory at 0x7C00.
[org 0x7c00]

; 16비트 리얼 모드로 실행합니다.
; Executes in 16-bit real mode.
bits 16

start:
    ; BIOS의 '한 글자 출력' 기능을 선택합니다.
    ; Select the BIOS 'print single character' function.
    mov ah, 0x0e

    ; 화면에 찍을 문자 'X'
    ; Character 'X' to display on the screen
    mov al, 'X'

    ; BIOS 비디오 인터럽트를 호출하여 문자를 출력합니다.
    ; Calls the BIOS video interrupt to output a character.
    int 0x10

    ; 현재 위치($)에서 무한 루프를 돌며 대기합니다.
    ; Waits in an infinite loop at the current location ($).
    jmp $

; 512바이트 중 빈 공간을 모두 0으로 채웁니다.
; Fill all remaining space within the 512 bytes with zeros.
times 510 - ($ - $$) db 0

; 이 디스크가 부팅 가능하다는 것을 알리는 값을 저장.
; Stores a value indicating that this disk is bootable.
dw 0xaa55
