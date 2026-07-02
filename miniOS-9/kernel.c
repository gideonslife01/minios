typedef unsigned char byte;

// ------------------------------------------------------------------------
// 1. 기본 그래픽 함수 (volatile 적용으로 메모리 강제 쓰기)
// Basic graphics functions (forced memory write via volatile)
// ------------------------------------------------------------------------
void draw_pixel(int x, int y, byte color) {
    volatile byte *vram = (volatile byte *)0xA0000;
    vram[(y * 320) + x] = color;
}

void clear_screen(byte color) {
    for (int y = 0; y < 200; y++) {
        for (int x = 0; x < 320; x++) {
            draw_pixel(x, y, color);
        }
    }
}

// ------------------------------------------------------------------------
// 2. 글자 출력 함수 (폰트 데이터를 함수 내부로 이동하여 링킹 오류 해결)
// Character output function (resolved linking errors by moving font data inside the function)
// ------------------------------------------------------------------------
void draw_char(int start_x, int start_y, int font_index, byte color) {
    // 링커 오류를 방지하기 위해 폰트 데이터를 함수 내부 지역 변수로 선언합니다.
    // To prevent linker errors, declare the font data as a local variable within the function.
    byte font_8x8[6][8] = {
        {0x18, 0x24, 0x42, 0x7E, 0x42, 0x42, 0x42, 0x00}, // A (index 0)
        {0x7C, 0x42, 0x42, 0x7C, 0x42, 0x42, 0x7C, 0x00}, // B (index 1)
        {0x3C, 0x42, 0x40, 0x40, 0x40, 0x42, 0x3C, 0x00}, // C (index 2)
        {0x78, 0x44, 0x42, 0x42, 0x42, 0x44, 0x78, 0x00}, // D (index 3)
        {0x7E, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7E, 0x00}, // E (index 4)
        {0x7E, 0x40, 0x40, 0x78, 0x40, 0x40, 0x40, 0x00}  // F (index 5)
    };

    for (int y = 0; y < 8; y++) {
        byte row_data = font_8x8[font_index][y];
        
        for (int x = 0; x < 8; x++) {
            // 비트 마스킹 연산으로 1인 부분만 점을 찍음
            // Plot points only at positions corresponding to 1s using bitmasking operations.
            if ((row_data & (0x80 >> x)) != 0) {
                draw_pixel(start_x + x, start_y + y, color);
            }
        }
    }
}

// ------------------------------------------------------------------------
// 3. 커널 메인 함수
// Kernel main function
// ------------------------------------------------------------------------
void kernel_main(void) {
    // 배경을 파란색(1)으로 초기화
    // Reset the background to blue (1).
    clear_screen(1);

    // 화면 중앙(X=100, Y=80) 근처에 다른 색상으로 A, B, C, D, E, F 출력
    // Display A, B, C, D, E, and F in different colors near the center of the screen (X=100, Y=80)
    draw_char(100, 80,  0, 15); // 흰색/white 'A'
    draw_char(112, 80,  1, 14); // 노란색/yellow 'B'
    draw_char(124, 80,  2, 10); // 초록색/green 'C'
    draw_char(136, 80,  3, 12); // 빨간색/red 'D'
    draw_char(148, 80,  4, 13); // 자색/Purple 'E'
    draw_char(160, 80,  5, 11); // 청록색/blue-green 'F'

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
