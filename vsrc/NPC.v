`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: NPC
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies: 本模块实现的是一个RV32IM指令集的处理器核心 本模块不使用任何always块，而是使用assign语句
// 在操作结束后变化pc，本模块的调用者会根据pc值读取一条指令，然后再次调用本模块，将读取到的指令作为inst输入
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module NPC (  //New Processor Core
    input         clk,         //时钟信号
    input         global_rst,  //全局复位
    input  [31:0] inst,        //指令
    output [31:0] pc,          //程序计数器
    output        ebreak       //ebreak
);
  wire init_rst;  //初始化复位
  Boot Boot_inst (
      .clk(clk),
      .global_rst(global_rst),
      .init_rst(init_rst)
  );
  wire        rst = global_rst | init_rst;
  wire        reg_we;  //寄存器组写使能
  wire        reg_rea;  //寄存器组读使能a
  wire        reg_reb;  //寄存器组读使能b
  wire [ 4:0] reg_addrw;  //寄存器组写选择信号
  wire [ 4:0] reg_addra;  //寄存器组读选择信号a
  wire [ 4:0] reg_addrb;  //寄存器组读选择信号b
  wire [31:0] reg_dinw;  //寄存器组写数据
  wire [31:0] reg_douta;  //寄存器组输出信号a
  wire [31:0] reg_doutb;  //寄存器组输出信号
  //通用寄存器组
  Regs #(
      .WIDTH     (32),  //每个寄存器位宽为32
      .ADDR_WIDTH(5),   //lg32
      .NR_REGS   (32),  //32个寄存器
      .RESET_VAL (0)
  ) Regs (
      .clk  (clk),
      .rst  (rst),
      .we   (reg_we),
      .rea  (reg_rea),
      .reb  (reg_reb),
      .addrw(reg_addrw),
      .addra(reg_addra),
      .addrb(reg_addrb),
      .dinw (reg_dinw),
      .douta(reg_douta),
      .doutb(reg_doutb)
  );
  //指令解码
  wire [6:0] opcode = inst[6:0];  //指令的操作码
  wire [4:0] rd = inst[11:7];  //R、I、U、J指令的目的寄存器
  wire [2:0] funct3 = inst[14:12];  //R、I、S、B指令的功能码
  wire [4:0] rs1 = inst[19:15];  //R、I、S、B指令的源寄存器1
  wire [4:0] rs2 = inst[24:20];  //R、S、B指令的源寄存器2
  wire [6:0] funct7 = inst[31:25];  //R指令的功能码
  wire [11:0] imm_i = inst[31:20];  //I指令的立即数
  wire [11:0] imm_s = {inst[31:25], inst[11:7]};  //S指令的立即数
  wire [12:0] imm_b = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};  //B指令的立即数
  wire [31:0] imm_u = {inst[31:12], 12'b0};  //U指令的立即数
  wire [20:0] imm_j = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};  //J指令的立即数
  //指令判断
  wire fmt_r = (opcode == 7'b0110011);  //R指令判断
  wire fmt_i_alu = (opcode == 7'b0010011);  //I指令运算组
  wire fmt_i_load = (opcode == 7'b0000011);  //I指令加载组
  wire fmt_i_jalr = (opcode == 7'b1100111);  //I指令返回组
  wire fmt_i_env = (opcode == 7'b1110011);  //I指令环境组
  wire fmt_i = (fmt_i_alu || fmt_i_load || fmt_i_jalr || fmt_i_env);  //I指令判断
  wire fmt_s = (opcode == 7'b0100011);  //S指令判断
  wire fmt_b = (opcode == 7'b1100011);  //B指令判断
  wire is_lui = (opcode == 7'b0110111);  //扩展赋值
  wire is_auipc = (opcode == 7'b0010111);  //扩展偏移赋值
  wire fmt_u = (is_lui || is_auipc);  //U指令判断
  wire fmt_j = (opcode == 7'b1101111);  //J指令判断
  wire is_jalxx = (fmt_j || fmt_i_jalr);
  //程序计数器
  wire is_jmp = (is_jalxx || fmt_b);  //以PC为结果
  wire [31:0] target_pc;  //跳转目标地址
  PC #(
      .START_ADDR(32'h80000000)
  ) PC_inst (
      .clk(clk),
      .global_rst(rst),
      .set_pc(is_jmp),
      .new_pc(target_pc),
      .pc(pc)
  );
  //参数设置和提取
  assign reg_rea = (fmt_u || fmt_j) ? 0 : 1;  //读使能a
  assign reg_reb = (fmt_i || fmt_u || fmt_j) ? 0 : 1;  //读使能b
  assign reg_we = (fmt_s || fmt_b) ? 0 : 1;  //写使能
  assign reg_addra = reg_rea ? rs1 : 0;  //读选择信号a
  assign reg_addrb = reg_reb ? rs2 : 0;  //读选择信号b
  assign reg_addrw = reg_we ? rd : 0;  //写选择信号
  wire [31:0] alu_out;
  //ALU计算
  wire [31:0] alu_in1;
  wire [ 1:0] alu_in1_sel = {is_lui, fmt_b};
  MuxKey #(
      .NR_KEY  (3),
      .KEY_LEN (2),
      .DATA_LEN(32)
  ) MuxKey_alu_in1 (
      .out(alu_in1),
      .key(alu_in1_sel),
      .inlines({
        {32'b0},  //lui
        {pc},  //fmt_b
        {reg_douta}  //others and default
      })
  );
  wire [31:0] alu_in2;
  wire [ 5:0] alu_in2_sel = {fmt_i, fmt_s, fmt_j, fmt_u, fmt_b, fmt_r};
  MuxMap #(
      .NR_KEY  (6),
      .KEY_LEN (6),
      .DATA_LEN(32)
  ) MuxMap_alu_in2 (
      .out(alu_in2),
      .key(alu_in2_sel),
      .lut({
        6'b100_000,  //i
        {20'b0, imm_i},
        6'b010_000,  //s
        {20'b0, imm_s},
        6'b001_000,  //j
        {11'b0, imm_j},
        6'b000_100,  //u
        {imm_u},
        6'b000_010,  //b
        {19'b0, imm_b},
        6'b000_001,  //r
        {reg_doutb}
      })
  );
  wire [2:0] alu_funct3 = funct3;
  wire [6:0] alu_funct7 = fmt_r ? funct7 : 7'h00;
  ALU32 ALU32_inst (
      .in1(fmt_i_env ? 0 : alu_in1),
      .in2(fmt_i_env ? 0 : alu_in2),
      .funct3(alu_funct3),
      .funct7(alu_funct7),
      .out(alu_out)
  );
  //如果是计算有关的，则把计算单元输出的数据连接到写入信号
  wire [31:0] ram_in = 0;  //TODO 连接内存输入
  assign reg_dinw = (fmt_r || fmt_i_alu) ? alu_out : fmt_i_load ? ram_in : 0;
  //写入PC的分类讨论和特例
  assign target_pc = is_jmp ? alu_out : (is_jalxx ? pc + 4 : 0);
  //ebreak
  assign ebreak = fmt_i_env && funct3 == 3'h0 && imm_i == 12'h001;



endmodule
