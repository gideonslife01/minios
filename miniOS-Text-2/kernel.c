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
                }
            }
        }
     
    }
}