#include <cstdint>
#include <iostream>
#ifndef _FAKE_VSCODE_LINT
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtop.h"  // 替换为顶层模块的文件名
#else
// 欺骗代码提示，假装存在这些类
typedef volatile uint64_t vluint64_t;
class Verilated {
 public:
  Verilated() = default;
  ~Verilated() = default;
  static void commandArgs(int argc, char **argv) {}
  static void traceEverOn(bool b) {}
};
class VerilatedVcdC {
 public:
  VerilatedVcdC() = default;
  ~VerilatedVcdC() = default;
  void open(const char *filename) {}
  void close() {}
  void dump(vluint64_t i) {}
};
struct Vtop {
  uint32_t clk;
  uint32_t rst;
  uint32_t ebreak;
  void eval() {}
  void final() {}
  void trace(VerilatedVcdC *vcd, int i) {}
};
#endif
void init(int argc, char **argv);
extern "C" {
uint32_t pmem_read(uint32_t addr);
}
std::string i10to16(uint32_t i);
std::string analyze(uint32_t inst);
volatile uint32_t ram[256 * 1024 / 4];  // 256k
volatile uint32_t code_len;
vluint64_t main_time = 0;  // 仿真时间变量
int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  init(argc, argv);
  // 实例化顶层模块
  Vtop *top = new Vtop;
  VerilatedVcdC *vcd = new VerilatedVcdC;
  top->trace(vcd, 999);
  vcd->open("build/trace.vcd");
  // 仿真开始
  //初始化拉高并维持一个周期
  top->rst = 1;
  top->clk = 0;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  top->clk = 1;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  //拉低信号
  top->clk = 0;
  top->rst = 0;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  // 周期开始
  std::cout << "====================cycle start=========================\n";
  do {
    // 时钟上升沿
    top->clk = 1;
    top->eval();
    vcd->dump(main_time);
    main_time += 2;
    // 时钟下降沿
    top->clk = 0;
    top->eval();
    vcd->dump(main_time);
    main_time += 2;
  } while (top->ebreak == 0);
  // 周期结束
  std::cout << "====================cycle end===========================\n";
  // 释放资源
  vcd->close();
  top->final();
  delete top;
  return 0;
}
extern "C" {
extern uint32_t pmem_read(uint32_t pc) {
  if (pc < 0x80000000 || pc >= (sizeof(ram) + 0x80000000)) {
    printf("req mem error: 0x%08x\n", pc);
    exit(1);
  }
  if (pc % 4 != 0) {
    std::cout << "Unaligned pc:" << pc << std::endl;
    exit(1);
  }
  return ram[(pc - 0x80000000) / 4];
}
}
void init(int argc, char **argv) {
  if (argc < 2) {
    std::cout << "Please input code file.\n" << std::endl;
    exit(1);
  }
  auto filename = argv[1];
  FILE *fp = fopen(filename, "rb");
  if (fp == NULL) {
    std::cout << "Open file failed.\n";
    exit(1);
  }
  fseek(fp, 0, SEEK_END);
  code_len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  fread((void *)ram, 1, code_len, fp);
  code_len /= 4;
  fclose(fp);
  for (int i = 0; i < code_len; i++) {
    printf("0x%08x: ", 0x80000000 + i * 4);
    std::cout << i10to16(ram[i]) << std::endl;
  }
  std::cout << "load binary is ok\n";
}
std::string i10to16(uint32_t i) {
  char bin[33] = {0};
  sprintf(bin, "0x%08x", i);
  return std::string(bin);
}
std::string analyze(uint32_t inst) {
  static char buf[256];
  if (inst == 0x00100073) {
    return "ebreak";
  }
  if ((inst & 0x7f) == 0x13 && ((inst >> 12) & 0x7) == 0x0) {
    return "addi";
  }
  if ((inst & 0x7f) == 0x6f) {
    auto i = inst;
    uint32_t rd_index = (((i) >> (7)) & ((1ull << ((11) - (7) + 1)) - 1));
    uint32_t imm =
        (({
           struct {
             int64_t n : 1;
           } __x = {.n = (((i) >> (31)) & ((1ull << ((31) - (31) + 1)) - 1))};
           (uint64_t) __x.n;
         })
         << 19) |
        ((((i) >> (12)) & ((1ull << ((19) - (12) + 1)) - 1)) << 12) |
        ((((i) >> (20)) & ((1ull << ((20) - (20) + 1)) - 1)) << 11) |
        ((((i) >> (25)) & ((1ull << ((30) - (25) + 1)) - 1)) << 5) |
        ((((i) >> (21)) & ((1ull << ((24) - (21) + 1)) - 1)) << 1);
    sprintf(buf, "jal %d, %d", rd_index, imm);
    return buf;
  }
  return "unknown inst";
}