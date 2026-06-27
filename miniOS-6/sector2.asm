[org 0x8000]
bits 16

start:
    ; ----------------------------------------------------
    ; 루프(반복문)를 사용하여 화면에 큼직한 사각형 그리기
    ; Draw a large rectangle on the screen using loops
    ; ----------------------------------------------------
    
    ; 사각형을 그리기 위한 시작 좌표 및 크기 설정
    ; Set starting coordinates and size for drawing the rectangle
    ; 시작 위치(Starting position): X=100, Y=50
    ; 사각형 크기(Size): 가로(Width)=50, 세로(Height)=30

    mov dx, 50          ; Y 좌표의 시작값 설정 (세로)
                        ; Set the starting value of the Y coordinate (Row)

draw_row_loop:
    mov cx, 100         ; 새 행(Row)을 시작할 때마다 X 좌표를 다시 100으로 초기화 (가로)
                        ; Reset X coordinate to 100 whenever starting a new row (Column)

draw_col_loop:
    ; BIOS 인터럽트를 사용해 현재 CX, DX 위치에 점 찍기
    ; Draw a pixel at the current CX, DX position using BIOS interrupt
    mov ah, 0x0c        ; 픽셀 쓰기 기능
                        ; Write graphics pixel function
    mov al, 14          ; 색상 번호 (14 = 노란색)
                        ; Color number (14 = Yellow)
    mov bh, 0           ; 페이지 번호 0
                        ; Page number 0
    int 0x10            ; 픽셀 출력
                        ; Output pixel

    inc cx              ; X 좌표를 오른쪽으로 1칸 이동
                        ; Move X coordinate 1 pixel to the right
    cmp cx, 150         ; 가로 길이가 50픽셀이 되었는지 확인 (100 + 50)
                        ; Check if the width reached 50 pixels (100 + 50)
    jl draw_col_loop    ; 150보다 작으면 계속 가로로 점 찍기
                        ; If less than 150, keep drawing pixels horizontally

    ; 가로 한 줄을 다 채웠으면 다음 줄(세로)로 이동
    ; Move to the next line (vertically) once a horizontal row is fully drawn
    inc dx              ; Y 좌표를 아래로 1칸 이동
                        ; Move Y coordinate 1 pixel down
    cmp dx, 80          ; 세로 높이가 30픽셀이 되었는지 확인 (50 + 30)
                        ; Check if the height reached 30 pixels (50 + 30)
    jl draw_row_loop    ; 80보다 작으면 다음 줄로 넘어가서 다시 가로 루프 실행
                        ; If less than 80, go to the next row and run the horizontal loop again

    ; 사각형 그리기가 끝나면 무한 루프로 대기
    ; Infinite loop waiting after rectangle drawing is finished
    jmp $

; 512바이트 크기 맞추기
; Fill up to 512 bytes
times 512 - ($ - $$) db 0
