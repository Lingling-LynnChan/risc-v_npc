`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: ALU
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ALU32 (  //算术逻辑单元
    input [31:0] in1,  //输入1
    input [31:0] in2,  //输入2
    input [6:0] funct7,  //子选择信号
    input [3:0] sel,  //运算选择
    output [31:0] out  //运算结果
);
  /*
i|sel|运算
0|add|加法 funct7==0x20减法
1|xor|异或
2|or |或
3|and|与
4|sll|逻辑左移
5|srl|逻辑右移 funct7==0x20算数右移
6|slt|有符号小于?1:0
7|sltu|无符号小于?1:0
*/
  /* verilator lint_off UNOPTFLAT */ wire [32*8-1:0] outNto1;  //N选一输入端
  MuxKey #(
      .NR_KEY  (8),
      .KEY_LEN (4),
      .DATA_LEN(32)
  ) MuxKey_inst (
      .out    (out),
      .key    (sel),
      .inlines(outNto1)
  );
  //0:加减法
  wire is_sub = funct7 == 7'h20;
  wire [31:0] in2_as = is_sub ? ~in2 : in2;
  wire cout;  //进位被忽略
  Adder #(
      .WIDTH(32)
  ) Adder32_inst (
      .c0  (is_sub),
      .in1 (in1),
      .in2 (in2_as),
      .sout(outNto1[32*1-1:0]),
      .cout(cout)
  );
  //1:异或
  assign outNto1[32*2-1:32*1] = in1 ^ in2;
  //2:或
  assign outNto1[32*3-1:32*2] = in1 | in2;
  //3:与
  assign outNto1[32*4-1:32*3] = in1 & in2;
  //4:逻辑左移

  //TODO
  assign outNto1[32*8-1:32*4] = 0;


endmodule
