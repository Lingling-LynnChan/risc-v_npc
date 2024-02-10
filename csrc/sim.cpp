#include <cstdint>
#include <iostream>
#define CLASS_NAME VAdder4
#ifndef _FAKE_VSCODE_LINT
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "VAdder4.h"  // 替换为顶层模块的文件名
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
struct CLASS_NAME {
  int c0;
  int in1;
  int in2;
  int sout;
  int cout;
  void eval() {}
  void final() {}
  void trace(VerilatedVcdC *vcd, int i) {}
};
#endif
struct resp_t {
  bool flag;
  uint64_t answer;
};
resp_t state_machine(CLASS_NAME *top);
vluint64_t main_time = 0;  // 仿真时间变量
int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  // 实例化顶层模块
  CLASS_NAME *top = new CLASS_NAME;
  VerilatedVcdC *vcd = new VerilatedVcdC;
  top->trace(vcd, 999);
  vcd->open("verilator/trace.vcd");
  // 仿真开始
  std::cout << "====================cycle start=========================\n";
  resp_t resp;
  while (resp = state_machine(top), resp.flag) {
    top->eval();
    vcd->dump(main_time++);
    if (resp.answer != top->cout + top->sout) {
      printf("%d+%d+%d!=%d+%d", top->in1, top->in2, top->c0, top->sout,
             top->cout);
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
resp_t state_machine(CLASS_NAME *top) {
  static int state = 0;
  uint64_t ans;
#define st(_c0, _in1, _in2)  \
  ({                         \
    top->c0 = _c0;           \
    top->in1 = _in1;         \
    top->in2 = _in2;         \
    ans = _c0 + _in1 + _in2; \
  })
  switch (state) {
    case 0:
      st(0, 0, 0);
      break;
    case 1:
      st(0, 0, 1);
      break;
    case 2:
      st(0, 1, 0);
      break;
    case 3:
      st(0, 1, 1);
      break;
    case 4:
      st(1, 1, 1);
      break;
    case 5:
      st(0, 15, 15);
      break;
    case 6:
      st(1, 15, 0);
      break;
    default:
      return resp_t{.flag = false, .answer = 0};
  }
  state++;
  return resp_t{.flag = true, .answer = ans};
}