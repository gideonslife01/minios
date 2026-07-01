typedef unsigned char byte;

// 1. 원하는 위치(x, y)에 원하는 색상(color)의 점을 찍는 함수
// 1. A function that plots a point of a specified color at a desired location (x, y).
void draw_pixel(int x, int y, byte color) {
    byte *vram = (byte *)0xA0000;
    // 320x200 해상도의 1차원 배열 위치 계산: (y * 320) + x
    // Calculation of 1D array position for 320x200 resolution: (y * 320) + x
    vram[(y * 320) + x] = color;
}

// 2. 원하는 위치, 크기, 색상으로 사각형을 그리는 함수
// 2. Function to draw a rectangle at a desired position, size, and color
void draw_rect(int start_x, int start_y, int width, int height, byte color) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // 위에서 만든 점 찍기 함수를 활용
            // Utilize the point-plotting function created above
            draw_pixel(start_x + x, start_y + y, color);
        }
    }
}

// 3. 커널 메인 함수
// 3. Kernel main function
void kernel_main(void) {
    // 예시 1: X=100, Y=50 위치에 가로 50, 세로 30 크기의 갈색(6) 사각형
    // Example 1: A brown (6) rectangle with a width of 50 and a height of 30 at position X=100, Y=50
    draw_rect(100, 50, 50, 30, 6);

    // 예시 2: 다른 위치에 파란색(9) 사각형 추가로 그리기 (색상 변경 테스트)
    // Example 2: Draw an additional blue (9) rectangle at a different location (color change test)
    draw_rect(200, 100, 40, 40, 9);
    
    // 예시 3: 다른 위치에 초록색(10) 사각형 추가로 그리기
    // Example 3: Draw an additional green (10) rectangle at a different location.
    draw_rect(30, 120, 60, 20, 10);

    // 작업 완료 후 CPU 대기
    // Wait for CPU after task completion
    while (1) {
        __asm__ __volatile__("hlt");
    }
}
