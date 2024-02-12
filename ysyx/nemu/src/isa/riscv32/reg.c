/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan
 *PSL v2. You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
 *KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 *NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include "local-include/reg.h"

#include <isa.h>

const char *regs[] = {"$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
                      "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
                      "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
                      "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};

void isa_reg_display() {
  int c = 0;
  printf("pc : 0x%08x\n", cpu.pc);
  for (int i = 0; i < 32; i++) {
    const char *name = reg_name(i, 32);
    word_t w = gpr(i);
    if (w == 0)
      printf("%-3s: 0         \t", name);
    else
      printf("%-3s: 0x%08x\t", name, w);
    c++;
    if (c % 8 == 0) {
      printf("\n");
    }
  }
}

word_t isa_reg_str2val(const char *s, bool *success) { return 0; }