[org 0x7c00]
bits 16

start:
    mov ax, 0
    mov ds, ax
    mov es, ax

    mov si, msg_boot
    call print_string

    ; 디스크 읽기 (2번 섹터부터 1개 섹터를 0x8000에 로드)
    ; Disk read (load 1 sector starting from sector 2 to 0x8000)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, 0x8000
    int 0x13

    jc disk_error

    mov si, msg_success
    call print_string

    ; 로드된 2번 섹터 코드로 점프
    ; Jump to loaded sector 2 code
    jmp 0x8000

disk_error:
    mov si, msg_error
    call print_string
    jmp hang

hang:
    jmp $

print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0e
    int 0x10
    jmp print_string
.done:
    ret

msg_boot    db '1. Booting MBR...', 13, 10, 0
msg_success db '2. Disk read success!', 13, 10, 0
msg_error   db 'Disk read failed!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xaa55
