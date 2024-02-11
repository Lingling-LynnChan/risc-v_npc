#include <cstdint>
#include <iostream>
#ifndef _FAKE_VSCODE_LINT
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "VNPC.h"  // 替换为顶层模块的文件名
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
struct VNPC {
  uint32_t clk;
  uint32_t global_rst;
  uint32_t inst;
  uint32_t pc;
  void eval() {}
  void final() {}
  void trace(VerilatedVcdC *vcd, int i) {}
};
#endif
void init(int argc, char **argv);
uint32_t pmem_read(uint32_t pc);
std::string i10to2(uint32_t i);
std::string analyze(uint32_t inst);
volatile uint32_t ram[256 * 1024 / 4];  // 256k
volatile uint32_t code_len;
vluint64_t main_time = 0;  // 仿真时间变量
int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  init(argc, argv);
  // 实例化顶层模块
  VNPC *top = new VNPC;
  VerilatedVcdC *vcd = new VerilatedVcdC;
  top->trace(vcd, 999);
  vcd->open("verilator/trace.vcd");
  // 仿真开始
  top->global_rst = 1;
  top->clk = 0;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  top->clk = 1;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  top->clk = 0;
  top->global_rst = 0;
  top->eval();
  vcd->dump(main_time);
  main_time += 2;
  // 周期开始
  std::cout << "====================cycle start=========================\n";
  for (int i = 0; i < code_len; ++i) {
    // 模拟时钟上升沿
    top->clk = 1;
    top->inst = pmem_read(top->pc);
    auto now_pc = top->pc;
    auto inst_bin = i10to2(top->inst);
    auto inst_asm = analyze(top->inst);
    top->eval();
    vcd->dump(main_time);
    main_time += 2;
    // 模拟时钟下降沿
    top->clk = 0;
    top->eval();
    vcd->dump(main_time);
    main_time += 2;
    // 当周期行为
    {
      printf("0x%x", now_pc);
      std::cout << ": " << inst_asm << " " << inst_bin << std::endl;
      if (inst_asm == "ebreak") {
        vcd->dump(main_time);
        main_time += 2;
        break;
      }
    }
  }
  // 周期结束
  std::cout << "====================cycle end===========================\n";
  // 释放资源
  vcd->close();
  top->final();
  delete top;
  return 0;
}
uint32_t pmem_read(uint32_t pc) {
  if (pc % 4 != 0) {
    std::cout << "Unaligned pc:" << pc << std::endl;
    exit(1);
  }
  return ram[(pc - 0x80000000) / 4];
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
    std::cout << "ram[" << i << "]: " << i10to2(ram[i]) << std::endl;
  }
  std::cout << "load binary is ok\n";
}
std::string i10to2(uint32_t i) {
  char bin[33];
  bin[0] = '\0';
  int j = 0;
  for (int k = 31; k >= 0; k--) {
    bin[j++] = ((i >> k) & 1) + '0';
  }
  bin[j] = '\0';
  return std::string(bin);
}
std::string analyze(uint32_t inst) {
  if (inst == 0x00100073) {
    return "ebreak";
  }
  if ((inst & 0x7f) == 0x13 && ((inst >> 12) & 0x7) == 0x0) {
    return "addi";
  }
  return "unknown inst";
}