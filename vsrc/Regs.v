`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: Regs
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


module Regs #(
    WIDTH = 1,
    ADDR_WIDTH = 1,
    NR_REGS = 1,
    RESET_VAL = 0
) (
    input clk,  //时钟
    input rst,  //复位
    input we,  //写使能
    input rea,  //读使能a
    input reb,  //读使能b
    input [ADDR_WIDTH-1:0] addrw,  //写地址
    input [ADDR_WIDTH-1:0] addra,  //读地址a
    input [ADDR_WIDTH-1:0] addrb,  //读地址b
    input [WIDTH-1:0] dinw,  //写数据
    output [WIDTH-1:0] douta,  //读输出a
    output [WIDTH-1:0] doutb  //读输出b
);
  wire [WIDTH-1:0] douts[NR_REGS];  //单个寄存器输出
  wire [NR_REGS*WIDTH-1:0] out_lines;  //总输出线

  begin
    Reg #(  //zero寄存器
        .WIDTH(WIDTH),
        .RESET_VAL(0)
    ) inst_zero (
        .clk (clk),
        .rst (rst),
        .din (dinw),
        .wen (0),
        .dout(douts[0])
    );
    assign out_lines[(WIDTH-1)-:WIDTH] = douts[0];
  end
  genvar i;
  generate
    for (i = 1; i < NR_REGS; i = i + 1) begin : Reg_Gen
      Reg #(
          .WIDTH(WIDTH),
          .RESET_VAL(RESET_VAL)
      ) inst (
          .clk (clk),
          .rst (rst),
          .din (dinw),
          .wen (we && (addrw == i)),
          .dout(douts[i])
      );
      assign out_lines[((i+1)*WIDTH-1)-:WIDTH] = douts[i];
    end
  endgenerate
  //读输出a
  MuxKey #(
      .NR_KEY  (NR_REGS),
      .KEY_LEN (ADDR_WIDTH),
      .DATA_LEN(WIDTH)
  ) mux_outa (
      .out(douta),
      .key(addra),
      .inlines(out_lines)
  );
  //读输出b
  MuxKey #(
      .NR_KEY  (NR_REGS),
      .KEY_LEN (ADDR_WIDTH),
      .DATA_LEN(WIDTH)
  ) mux_outb (
      .out(doutb),
      .key(addrb),
      .inlines(out_lines)
  );

endmodule  //Regs

