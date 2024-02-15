`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: PC
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


module PC #(  //Program Counter
    START_ADDR = 32'h80000000
) (
    input wire clk,
    input wire rst,
    input wire set_pc,
    input wire [31:0] new_pc,
    output wire [31:0] pc
);
  wire [31:0] wpc = set_pc ? new_pc : pc + 4;
  Reg #(
      .WIDTH(32),
      .RESET_VAL(START_ADDR)
  ) reg_pc (
      .clk (clk),
      .rst (rst),
      .din (wpc),
      .wen (1),
      .dout(pc)
  );
endmodule
