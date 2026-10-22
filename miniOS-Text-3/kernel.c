typedef unsigned char byte;
typedef unsigned short word; //✅ miniOS-Text-2 add

// ----------------------------------------------------
// ✅ miniOS-Text-2
// I/O 포트에서 1바이트를 읽어오는 함수 (x86 'inb' 명령어)
// Read 1 byte from I/O port
// ----------------------------------------------------
static inline byte inb(word port) {
    byte ret;
    __asm__ __volatile__("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// ----------------------------------------------------
// ✅ miniOS-Text-3
// I/O 포트에 1바이트를 쓰는 함수 (x86 'outb' 명령어)
// A function that writes 1 byte to an I/O port (x86 'outb' instruction)
// ----------------------------------------------------
static inline void outb(word port, byte value) {
    __asm__ __volatile__("outb %0, %1" : : "a"(value), "Nd"(port));
}

// ----------------------------------------------------
// ✅ miniOS-Text-2
// PS/2 키보드 스캔코드(Set 1)를 기본 ASCII 문자로 변환하는 매핑 테이블
// PS/2 Keyboard Scancode (Set 1) to ASCII conversion table
// ----------------------------------------------------
char scancode_to_ascii(byte scancode) {
    // 키보드 Set 1 주요 키 매핑 (영문 소문자, 숫자, 일부 특수문자)
    // Key mappings for Keyboard Set 1 (lowercase English letters, numbers, and select special characters)
    char table[128] = {
        0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
        '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
        0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
        0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
        '*', 0, ' '
    };
    
    if (scancode < 128) {
        return table[scancode];
    }
    return 0;
}


// ----------------------------------------------------
// ✅ miniOS-Text-3
// 커서 업데이트 함수
// Cursor update function
// ----------------------------------------------------
// 화면(해상도)는 가로 80글자 세로25줄로 고정되어 있음.
// The screen (resolution) is fixed at 80 characters wide by 25 lines high.
void update_cursor(int x, int y) {
    // 화면은 가로 80글자, 세로 25줄이므로 전체 위치(오프셋) 계산
    // Since the screen is 80 characters wide and 25 lines high, calculate the total position (offset)
    unsigned short cursorLocation = y * 80 + x;

    // 1. 커서 위치의 '하위 8비트'를 설정하기 위해 인덱스 0x0F 선택
    // Select index 0x0F to set the 'lower 8 bits' of the cursor position.
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(cursorLocation & 0xFF));

    // 2. 커서 위치의 '상위 8비트'를 설정하기 위해 인덱스 0x0E 선택
    // Select index 0x0E to set the 'upper 8 bits' of the cursor position
    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)((cursorLocation >> 8) & 0xFF));
}

// ----------------------------------------------------
// ✅ miniOS-Text-3
// 스크롤 함수
// Scroll function
// ----------------------------------------------------
// 
int scroll_screen(void) {
    unsigned short* vram = (unsigned short*) 0xB8000;

    // 1. 1번 줄부터 마지막 줄까지의 데이터를 한 줄씩 위로 복사
    // Copy the data from the first row through the last row, one row at a time, to the row above.
    for (int i = 0; i < 24 * 80; i++) {
        vram[i] = vram[i + 80];
    }

    // 2. 가장 아랫줄(24번째 줄)은 빈 칸으로 채우기
    // Fill the bottom row (the 24th row) with empty spaces.
    for (int i = 24 * 80; i < 25 * 80; i++) {
        // 흰색 공백 (속성 0x0F + 문자 ' ')
        // White space (attribute 0x0F + character ' ')
        vram[i] = (0x0F << 8) | ' '; 
    }

    // 3. 맨 아랫줄의 시작점으로 커서 위치 반환
    // Return the cursor position to the start of the bottom line
    return 24 * 80;
}

void kernel_main(void) {
    // VGA 텍스트 모드 비디오 메모리 시작 주소
    // Start address of VGA text mode video memory
    volatile char *vram = (volatile char *)0xB8000;
    
    const char *msg = "Shell Version = 1.0.3! Type keys:\n";
    int i = 0;
    
    while (msg[i] != '\0') {
        vram[i * 2]     = msg[i];       // 짝수 바이트: ASCII 문자 / Even-numbered bytes: ASCII characters
        vram[i * 2 + 1] = 0x0F;         // 홀수 바이트: 흰색 글자, 검은 배경 속성 / Odd-numbered bytes: white text, black background attribute
        i++;
    }

    // ✅ miniOS-Text-2 
    // 현재 문자가 찍힐 화면 커서 위치 추적 
    // Track the screen cursor position where the current character will be displayed

    int cursor = i; 

    while (1) {
        // ✅ miniOS-Text-2
        // 1. 키보드 컨트롤러 상태 포트(0x64) 확인
        // Check the keyboard controller status port (0x64)        
        byte status = inb(0x64);
        
        // 2. 비트 0(Output Buffer Full)이 1이면 읽어올 키 입력 데이터가 존재함
        // If bit 0 (Output Buffer Full) is 1, it means there is key input data available to be read.        
        if (status & 0x01) {

            // 데이터 포트(0x60)에서 스캔코드 읽기
            // Read scan code from data port (0x60)
            byte scancode = inb(0x60); 
            
            // 3. 스캔코드의 최상위 비트(0x80)가 켜져 있으면 '키 떼기(Release)' 이벤트이므로 무시
            // If the scan code's most significant bit (0x80) is on, it is a 'Release' event, so ignore.
            if (!(scancode & 0x80)) {
                char c = scancode_to_ascii(scancode);
                if (c != 0) {
                    // 화면에 글자 출력 / Display text on the screen
                    vram[cursor * 2]     = c;
                    vram[cursor * 2 + 1] = 0x0F; // 흰색 글자 / White text
                    cursor++;

                    // ✅ miniOS-Text-3
                    // 화면을 꽉 채웠는지 검사 (25줄 * 80글자 = 2000)
                    // Check if the screen is completely filled (25 lines * 80 characters = 2000)
                    if (cursor >= 2000) {
                        // 스크롤 후 갱신된 커서 위치를 다시 받아옴
                        // Retrieve the updated cursor position after scrolling
                        cursor = scroll_screen(); 
                    }

                    // ✅ miniOS-Text-3
                    // 커서 좌표 계산해서 하드웨어 커서 업데이트 
                    // Calculate cursor coordinates and update the hardware cursor
                    // (x = cursor % 80, y = cursor / 80)
                    update_cursor(cursor % 80, cursor / 80);
                }
            }
        }
     
    }
}