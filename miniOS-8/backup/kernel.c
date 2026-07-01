#define SCREEN_WIDTH  320
#define SCREEN_HEIGHT 200

// 함수가 텍스트 섹션의 최상단 규격에 맞게 정렬되도록 지정
// Ensure the function is aligned correctly in the text section
void c_main(void) __attribute__((section(".text")));

void c_main(void) {
    // 0xA0000 그래픽 비디오 메모리(VRAM) 주소 포인터
    // 0xA0000 Graphic Video Memory (VRAM) address pointer
    unsigned char* vram = (unsigned char*)0xA0000;

    int start_x = 100;
    int start_y = 50;
    int width = 50;
    int height = 30;
    
    // 보라색 (Mode 13h 표준 팔레트 기준)
    // Purple color (Based on Mode 13h standard palette)
    unsigned char color = 13; 

    // 화면에 50x30 크기의 보라색 사각형 그리기
    // Draw a 50x30 size purple rectangle on the screen
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // 현재 픽셀의 VRAM 오프셋 계산
            // Calculate the VRAM offset for the current pixel
            int offset = ((start_y + y) * SCREEN_WIDTH) + (start_x + x);
            vram[offset] = color;
        }
    }

    // 컴파일러가 무한루프를 최적화하여 지워버리는 것을 방지
    // Prevent the compiler from optimizing out the infinite loop
    while(1) {
        __asm__ __volatile__("hlt");
    }
}
