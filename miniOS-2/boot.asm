; BIOS가 이 코드를 메모리 0x7C00에 로드합니다.
; The BIOS loads this code into memory at 0x7C00.
[org 0x7c00]

; 16비트 리얼 모드로 실행합니다.
; Executes in 16-bit real mode.
bits 16

start:
    ; 데이터 세그먼트 레지스터 초기화
    ; Initialize data segment register
    mov ax, 0
    mov ds, ax

    ; 문자열의 시작 주소를 SI 레지스터에 저장
    ; Store the starting address of the string in the SI register
    mov si, msg

; 문자열을 한 글자씩 읽어와 출력하는 루프
; A loop that reads and prints a string character by character
print_loop:
    ; SI가 가리키는 주소에서 1바이트를 AL에 로드하고 SI를 1 증가시킴
    ; Load 1 byte from the address pointed to by SI into AL and increment SI by 1
    lodsb           

    ; 가져온 문자가 0(문자열의 끝)인지 확인
    ; Check if the retrieved character is 0 (end of string)
    cmp al, 0     

    ; 0이면 무한 루프로 이동하여 종료
    ; If 0, jump to the infinite loop and terminate.
    je hang         

    ; BIOS 텔레타이프 출력 기능 선택
    ; Select BIOS teletype output function
    mov ah, 0x0e    

    ; BIOS 비디오 인터럽트 호출하여 AL의 문자 출력
    ; Call BIOS video interrupt to output the character in AL
    int 0x10       

    ; 다음 글자 출력을 위해 루프 반복
    ; Loop to print the next character
    jmp print_loop  

; 현재 위치($)에서 무한 루프를 돌며 대기합니다.
; Waits in an infinite loop at the current location ($).
hang:
    jmp $

; 출력할 문자열 정의 (끝에 0을 붙여 문자열의 끝을 표시)
; Define the string to output (append 0 to mark the end of the string)
msg db 'Hello miniOS!', 0

; 512바이트 중 빈 공간을 모두 0으로 채웁니다.
; Fill all remaining space within the 512 bytes with zeros.
times 510 - ($ - $$) db 0

; 이 디스크가 부팅 가능하다는 것을 알리는 부트 시그니처 저장
; Store the boot signature indicating that this disk is bootable.
dw 0xaa55
