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
    input [2:0] funct3,  //运算选择
    input [6:0] funct7,  //子选择信号
    output [31:0] out  //运算结果
);
  wire [32*8-1:0] outNto1;  //N选一输入端
  MuxKey #(
      .NR_KEY  (8),
      .KEY_LEN (3),
      .DATA_LEN(32)
  ) MuxKey_inst (
      .out    (out),
      .key    (funct3),
      .inlines(outNto1)
  );
  //0:加减法
  wire add_en = funct3 == 3'h0;
  wire is_sub = add_en ? (funct7 == 7'h20) : 0;
  wire [31:0] in2_as = add_en ? (is_sub ? ~in2 : in2) : 0;
  wire cout;  //进位被忽略
  Adder #(
      .WIDTH(32)
  ) Adder32_inst (
      .en  (add_en),
      .c0  (is_sub),
      .in1 (in1),
      .in2 (in2_as),
      .sout(outNto1[32*1-1:0]),
      .cout(cout)
  );
  //异或
  assign outNto1[32*5-1:32*4] = in1 ^ in2;
  //或
  assign outNto1[32*7-1:32*6] = in1 | in2;
  //与
  assign outNto1[32*8-1:32*7] = in1 & in2;
  //左右移
  wire is_left = funct3 == 3'h1;
  wire is_right = funct3 == 3'h5;
  wire shift_en = is_left || is_right;
  wire is_logical = is_right ? (funct7 == 7'h00) : 0;
  wire [31:0] shift_out;
  Shift #(
      .WIDTH(32)
  ) Shift_inst (
      .en        (shift_en),
      .in1       (in1),
      .in2       (in2),
      .is_left   (is_left),
      .is_logical(is_logical),
      .out       (shift_out)
  );
  assign outNto1[32*6-1:32*5] = shift_out;
  assign outNto1[32*2-1:32*1] = shift_out;
  //比较
  wire is_slt = funct3 == 3'h2;
  assign outNto1[32*3-1:32*2] = is_slt ? ($signed(in1) < $signed(in2) ? 1 : 0) : 0;
  wire is_sltu = funct3 == 3'h3;
  assign outNto1[32*4-1:32*3] = is_sltu ? ((in1 < in2) ? 1 : 0) : 0;
endmodule
