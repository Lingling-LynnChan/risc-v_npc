#include <cstdint>
#include <iostream>
#ifndef _IN_VSCODE
#include <verilated.h>
#include "VNPC.h" // 替换为顶层模块的文件名
#else
// 欺骗代码提示，假装存在这些类
class Verilated
{
public:
  Verilated() = default;
  ~Verilated() = default;
  static void commandArgs(int argc, char **argv) {}
};
struct VNPC
{
  int clk;
  int global_rst;
  int inst;
  int pc;
  void eval() {}
  void final() {}
};
#endif
void init_pmem(int argc, char **argv);
int pmem_read(int pc);
char *i10to2(int i);
void analyze(int inst);
int32_t ram[256 * 1024 / 4]; // 256k
int32_t code_len;
int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);
  init_pmem(argc, argv);
  // 实例化顶层模块
  VNPC *top = new VNPC; // 替换为顶层模块的类名
  top->global_rst = 1;
  top->clk = 0;
  top->eval();
  top->clk = 1;
  top->eval();
  top->clk = 0;
  top->global_rst = 0;
  top->eval();
  // 初始化模拟时钟
  // 时钟周期数
  std::cout << "==========cycle start==========\n";
  for (int i = 0; i < code_len; ++i)
  {
    // 模拟时钟上升沿
    top->clk = 1;
    top->inst = pmem_read(top->pc);
    std::cout << "pc: " << top->pc << std::endl;
    std::cout << "inst: " << i10to2(top->inst) << std::endl;
    top->eval();
    analyze(top->inst);
    // 模拟时钟下降沿
    top->clk = 0;
    top->eval();
  }
  std::cout << "===========cycle end===========\n";
  // 释放资源
  top->final();
  delete top;
  return 0;
}
int pmem_read(int pc)
{
  if (pc % 4 != 0)
  {
    std::cout << "Unaligned pc:" << pc << std::endl;
    exit(1);
  }
  return ram[pc / 4];
}
void init_pmem(int argc, char **argv)
{
  if (argc < 2)
  {
    std::cout << "Please input code file.\n"
              << std::endl;
    exit(1);
  }
  auto filename = argv[1];
  FILE *fp = fopen(filename, "rb");
  if (fp == NULL)
  {
    std::cout << "Open file failed.\n";
    exit(1);
  }
  fseek(fp, 0, SEEK_END);
  code_len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  fread(ram, 1, code_len, fp);
  code_len /= 4;
  fclose(fp);
  for (int i = 0; i < code_len; i++)
  {
    std::cout << "ram[" << i << "]: " << i10to2(ram[i]) << std::endl;
  }
  std::cout << "load binary is ok\n";
}
char *i10to2(int i)
{
  static char bin[33];
  bin[0] = '\0';
  int j = 0;
  for (int k = 31; k >= 0; k--)
  {
    bin[j++] = ((i >> k) & 1) + '0';
  }
  bin[j] = '\0';
  return bin;
}
void analyze(int inst)
{
  if (inst == 0x00100073)
  {
    std::cout << "ebreak\n";
    exit(0);
  }
  if ((inst & 0x7f) == 0x13 && ((inst >> 12) & 0x7) == 0x0)
  {
    std::cout << "addi\n";
  }
}