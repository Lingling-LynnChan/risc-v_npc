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
    input  [31:0] in1,  //输入1
    input  [31:0] in2,  //输入2
    input  [ 3:0] sel,  //运算选择
    output [31:0] out   //运算结果
);  /*
i|sel|运算
0|add|加法
1|sub|减法
2|xor|异或
3|or |或
4|and|与
5|sll|逻辑左移
6|srl|逻辑右移
7|sra|算数右移
8|slt|有符号小于?1:0
9|sltu|无符号小于?1:0
*/
  wire [31:0] outNto1[10];  //N选一输入端
  MuxKey # (
    .NR_KEY(10)
    .KEY_LEN(4),
    .DATA_LEN(32)
  )
  MuxKey_inst (
    .out(out),
    .key(sel),
    .inlines(outNto1)
  );
  //加减法
  wire is_sub = sel == 3'b001;
  wire [31:0] in2_as = is_sub ? ~in2 : in2;
  Adder32 Adder32_inst (
      .c0  (is_sub),
      .in1 (in1),
      .in2 (in2_as),
      .sout(outNto1[0]),
      .cout()
  );
  //加减一致
  assign outNto1[1] = outNto1[0];
  //异或
  assign outNto1[2] = in1 ^ in2;
  //或
  assign outNto1[3] = in1 | in2;


endmodule
