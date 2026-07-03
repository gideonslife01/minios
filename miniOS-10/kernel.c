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
void draw_char(int start_x, int start_y, char c, byte color) {
    // A부터 Z까지 총 26개의 알파벳 대문자 8x8 폰트 데이터 세트
    byte font_8x8[26][8] = {
        {0x18, 0x24, 0x42, 0x7E, 0x42, 0x42, 0x42, 0x00}, // 'A' (index 0)
        {0x7C, 0x42, 0x42, 0x7C, 0x42, 0x42, 0x7C, 0x00}, // 'B' (index 1)
        {0x3C, 0x42, 0x40, 0x40, 0x40, 0x42, 0x3C, 0x00}, // 'C' (index 2)
        {0x78, 0x44, 0x42, 0x42, 0x42, 0x44, 0x78, 0x00}, // 'D' (index 3)
        {0x7E, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7E, 0x00}, // 'E' (index 4)
        {0x7E, 0x40, 0x40, 0x78, 0x40, 0x40, 0x40, 0x00}, // 'F' (index 5)
        {0x3C, 0x42, 0x40, 0x4E, 0x42, 0x42, 0x3C, 0x00}, // 'G' (index 6)
        {0x42, 0x42, 0x42, 0x7E, 0x42, 0x42, 0x42, 0x00}, // 'H' (index 7)
        {0x3E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x3E, 0x00}, // 'I' (index 8)
        {0x03, 0x01, 0x01, 0x01, 0x41, 0x41, 0x3E, 0x00}, // 'J' (index 9)
        {0x42, 0x44, 0x48, 0x70, 0x48, 0x44, 0x42, 0x00}, // 'K' (index 10)
        {0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7E, 0x00}, // 'L' (index 11)
        {0x42, 0x66, 0x5A, 0x42, 0x42, 0x42, 0x42, 0x00}, // 'M' (index 12)
        {0x42, 0x62, 0x52, 0x4A, 0x46, 0x42, 0x42, 0x00}, // 'N' (index 13)
        {0x3C, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3C, 0x00}, // 'O' (index 14)
        {0x7C, 0x42, 0x42, 0x7C, 0x40, 0x40, 0x40, 0x00}, // 'P' (index 15)
        {0x3C, 0x42, 0x42, 0x42, 0x4A, 0x44, 0x3A, 0x00}, // 'Q' (index 16)
        {0x7C, 0x42, 0x42, 0x7C, 0x48, 0x44, 0x42, 0x00}, // 'R' (index 17)
        {0x3C, 0x40, 0x40, 0x3C, 0x02, 0x02, 0x3C, 0x00}, // 'S' (index 18)
        {0x7E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00}, // 'T' (index 19)
        {0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3C, 0x00}, // 'U' (index 20)
        {0x42, 0x42, 0x42, 0x42, 0x42, 0x24, 0x18, 0x00}, // 'V' (index 21)
        {0x42, 0x42, 0x42, 0x42, 0x5A, 0x66, 0x42, 0x00}, // 'W' (index 22)
        {0x42, 0x42, 0x24, 0x18, 0x24, 0x42, 0x42, 0x00}, // 'X' (index 23)
        {0x42, 0x42, 0x24, 0x18, 0x18, 0x18, 0x18, 0x00}, // 'Y' (index 24)
        {0x7E, 0x02, 0x04, 0x08, 0x16, 0x20, 0x7E, 0x00}  // 'Z' (index 25)
    };

    // 문자에 맞는 폰트 인덱스 계산 ('A'를 빼서 0~25로 변환)
    // Calculate the font index for the character (subtract 'A' to convert to a range of 0–25)
    int font_index = 0;

    //  'A'에서 'Z'까지 범위 검사
    // Check range from 'A' to 'Z'
    if (c >= 'A' && c <= 'Z') { 
        font_index = c - 'A';
    } else {
        return; 
    }

    for (int y = 0; y < 8; y++) {
        byte row_data = font_8x8[font_index][y];

        for (int x = 0; x < 8; x++) {
            if ((row_data & (0x80 >> x)) != 0) {
                draw_pixel(start_x + x, start_y + y, color);
            }
        }
    }
}


// ------------------------------------------------------------------------
// 3. [새로 추가] 문자열을 통째로 넘기면 가로로 정렬해 그려주는 함수
// [New Addition] A function that draws a string horizontally when passed as a whole.
// ------------------------------------------------------------------------
void draw_string(int start_x, int start_y, const char *str, byte color) {
    int current_x = start_x;
    
    // 문자열의 끝('\0')을 만날 때까지 한 글자씩 반복수행
    // Iterate character by character until the end of the string ('\0') is reached
    for (int i = 0; str[i] != '\0'; i++) {

        // 공백 문자(' ') 처리: 글자를 그리지는 않고 가로로 8픽셀 건너뜀
        // Handle space character (' '): Skip 8 pixels horizontally without drawing a character.
        if (str[i] == ' ') {
            current_x += 8;
            continue;
        }

        // 현재 글자 그리기 / Drawing current characters
        draw_char(current_x, start_y, str[i], color);
        
        // 다음 글자는 가로로 8픽셀 뒤에 그려지도록 좌표 이동 (글자 크기가 8x8이므로)
        // Shift the coordinates to draw the next character 8 pixels to the right (since the character size is 8x8).
        current_x += 8;
    }
}

// ------------------------------------------------------------------------
// 4. 커널 메인 함수
// Kernel main function
// ------------------------------------------------------------------------
void kernel_main(void) {
    clear_screen(1); // 파란 배경 / Blue background

    // -- 함수 한 줄로 문자열 통째로 화면에 출력하기! (현재 폰트는 A~F와 공백만 인식 가능)  -- //
    // -- Print an entire string to the screen with a single function call! (The current font only supports A–F and spaces.) -- //

    // 노란색(14)으로 "I WANT TO" 출력 / Output "BAD CAFE" in yellow (14).
    draw_string(80, 70, "I WANT TO", 14);  

    // 흰색(15)으로 "BREAKE FREE" 출력 / Print "DECADE FACE" in white (15).
    draw_string(80, 90, "BREAKE FREE", 15); 

    // 빨간색(12)으로 "QUEEN" 출력 / Output "FADE" in red (12).
    draw_string(80, 110, "QUEEN", 12);        

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
