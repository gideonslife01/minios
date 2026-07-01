/* ----------------------------------------------------
   출력 포맷 설정: OS 커널 생성을 위한 순수 바이너리 형태
   Output Format: Pure binary format for OS kernel generation
   ---------------------------------------------------- */
OUTPUT_FORMAT("binary")

/* ----------------------------------------------------
   프로그램 시작점 설정: sector2.asm의 start 라벨
   Entry Point: start label in sector2.asm
   ---------------------------------------------------- */
ENTRY(start)

SECTIONS
{
    /* ----------------------------------------------------
       커널이 메모리에 로드될 시작 주소 (0x8000) 설정
       Set the starting address (0x8000) where the kernel is loaded into memory
       ---------------------------------------------------- */
    . = 0x8000;

    /* ----------------------------------------------------
       코드 섹션 정의: sector2.o의 코드가 무조건 맨 앞에 오도록 배치 (순서 변경 금지)
       Code Section: Ensure sector2.o code is placed at the very beginning (Do not change order)
       ---------------------------------------------------- */
    .text : {
        sector2.o(.text)
        kernel.o(.text)
        *(.text)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}
