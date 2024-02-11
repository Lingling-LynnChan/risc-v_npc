// 这是一个朴素的测试程序
#define asmv asm volatile
// ===============================
#define ebreak() asmv("ebreak")
#define addi(rd, rs1, imm) asmv("addi " #rd ", " #rs1 ", " #imm)

void _start() {
  addi(a1, x0, 2);
  ebreak();
}
