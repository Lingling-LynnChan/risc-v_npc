`timescale 1ns / 1ps

module top (
    input  wire clk,
    input  wire rst,
    output wire ebreak
);
  reg [31:0] inst;
  wire [31:0] pc;
  import "DPI-C" function bit [31:0] pmem_read(input bit [31:0] addr);
  assign inst = pmem_read(pc);
  GPC GPC_inst (
      .clk(clk),
      .rst(rst),
      .inst(inst),
      .pc(pc),
      .ebreak(ebreak)
  );

endmodule
