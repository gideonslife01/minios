typedef unsigned char byte;

void kernel_main(void) {
    // VGA 텍스트 모드 비디오 메모리 시작 주소
    // Start address of VGA text mode video memory
    volatile char *vram = (volatile char *)0xB8000;
    
    const char *msg = "Shell Version = 1.0.2!";
    int i = 0;
    
    while (msg[i] != '\0') {
        vram[i * 2]     = msg[i];       // 짝수 바이트: ASCII 문자 / Even-numbered bytes: ASCII characters
        vram[i * 2 + 1] = 0x0F;         // 홀수 바이트: 흰색 글자, 검은 배경 속성 / Odd-numbered bytes: white text, black background attribute
        i++;
    }

    while (1) {
     
    }
}