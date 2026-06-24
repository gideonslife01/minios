[org 0x8000]
bits 16

start:
    mov si, msg_next_sector
    call print_string
    
    ; 대기모드 / Standby mode
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

msg_next_sector db '3. Hello from Sector 2 (0x8000)!', 13, 10, 0

times 512 - ($ - $$) db 0
