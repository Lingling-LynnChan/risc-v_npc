# RISC-V 指令集的处理器

> 还是先以实现功能为主吧

## RISC-V 指令集

### 核心指令格式
| 31________________25 | 24______________20 | 19______15 | 14______12 | 11_______________7 | 6_____0 | Type   |
| -------------------- | :----------------- | ---------- | ---------- | ------------------ | ------- | ------ |
| funct7               | rs2                | rs1        | funct3     | rd                 | opcode  | R-Type |
| imm[11:5]            | imm[4:0]           | rs1        | funct3     | rd                 | opcode  | I-Type |
| imm[11:5]            | rs2                | rs1        | funct3     | imm[4:0]           | opcode  | S-Type |
| {imm[12],imm[10:5]}  | rs2                | rs1        | funct3     | {imm[4:1],imm[11]} | opcode  | B-Type |
| imm[31:25]           | imm[24:20]         | imm[19:15] | imm[14:12] | rd                 | opcode  | U-Type |
| {imm[20],imm[10:5]}  | {imm[4:1],imm[11]} | imm[19:15] | imm[14:12] | rd                 | opcode  | J-Type |

# RV32I BASE INTEGER INSTRUCTIONS

| Inst | Name               | Type | Opcode  | Funct3 | Funct7 | Description(C)  | Note |
| ---- | ------------------ | ---- | ------- | ------ | ------ | --------------- | ---- |
| add  | ADD                | R    | 0110011 | 0x0    | 0x00   | rd = rs1 + rs2  |      |
| sub  | SUB                | R    | 0110011 | 0x0    | 0x20   | rd = rs1 - rs2  |      |
| xor  | XOR                | R    | 0110011 | 0x4    | 0x00   | rd = rs1 ^ rs2  |      |
| or   | OR                 | R    | 0110011 | 0x6    | 0x00   | rd = rs1 \| rs2 |      |
| and  | AND                | R    | 0110011 | 0x7    | 0x00   | rd = rs1 & rs2  |      |
| sll  | Shift Left Logical | R    | 0110011 | 0x1    | 0x00   | rd = rs1 << rs2 |      |
| srl  |
| sra  |
| slt  |
| sltu |
| addi |
| xori |
| ori  |
| andi |
