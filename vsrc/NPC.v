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
    output [31:0] pc           //程序计数器
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
  wire fmt_i = (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b1100111);  //I指令判断
  wire fmt_s = (opcode == 7'b0100011);  //S指令判断
  wire fmt_b = (opcode == 7'b1100011);  //B指令判断
  wire fmt_u = (opcode == 7'b0110111) || (opcode == 7'b0010111);  //U指令判断
  wire fmt_j = (opcode == 7'b1101111);  //J指令判断
  //程序计数器
  wire is_jmp = fmt_j || fmt_b;  //是否跳转
  wire [31:0] target_pc = 0;  //TODO 跳转目标地址
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
  assign reg_rea   = (fmt_r || fmt_i || fmt_s || fmt_b) ? 1 : 0;  //读使能a
  assign reg_addra = reg_rea ? rs1 : 0;  //读选择信号a
  wire [31:0] rsa_data = reg_rea ? reg_douta : fmt_u ? imm_u : fmt_j ? {11'b0,imm_j} : 0;  //源数据a
  assign reg_reb   = (fmt_r || fmt_s || fmt_b) ? 1 : 0;  //读使能b
  assign reg_addrb = reg_reb ? rs2 : 0;  //读选择信号b
  wire [31:0] rsb_data = reg_reb ? reg_doutb : fmt_i ? {20'b0, imm_i} : 0;  //源数据b
  assign reg_we = (fmt_r || fmt_i || fmt_u || fmt_j) ? 1 : 0;  //写使能
  assign reg_addrw = (fmt_r || fmt_i || fmt_u || fmt_j) ? rd : 0;  //写选择信号
  wire [31:0] reg_dinw_alu;
  //ALU计算
  wire [ 3:0] alu_out;
  MuxMap #(  //bug: 为什么输入 0x0, 0x00 输出 1(本该是0)
      .NR_KEY  (8),
      .KEY_LEN (3),
      .DATA_LEN(4)
  ) MuxMap_inst (
      .out(alu_out),
      .key(funct3),
      .lut({
        3'h0,
        4'd0,  //add
        3'h4,
        4'd1,  //xor
        3'h6,
        4'd2,  //or
        3'h7,
        4'd3,  //and
        3'h1,
        4'd4,  //sll
        3'h5,
        4'd5,  //srx
        3'h2,
        4'd6,  //slt
        3'h3,
        4'd7  //sltu
      })
  );
  ALU32 ALU32_inst (
      .in1(reg_douta),
      .in2(fmt_i ? {20'b0, imm_i} : reg_doutb),
      .funct7(fmt_r ? funct7 : 7'h00),
      .sel(alu_out),
      .out(reg_dinw_alu)
  );
  //如果是计算有关的，则把计算单元输出的数据连接到写入信号
  //TODO 还有U和J没有处理
  assign reg_dinw = (fmt_r || fmt_i) ? reg_dinw_alu : 0;



endmodule
