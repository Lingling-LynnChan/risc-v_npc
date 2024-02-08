// 这是一个朴素的测试程序
void _start()
{
  asm volatile(
      "addi a0, x0, %0" ::"i"(12));
  asm volatile("ebreak");
}