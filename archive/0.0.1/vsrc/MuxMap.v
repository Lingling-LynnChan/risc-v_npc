`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: MuxMap
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


module MuxMap #(
    NR_KEY   = 2,
    KEY_LEN  = 1,
    DATA_LEN = 1
) (
    output reg [DATA_LEN-1:0] out,
    input [KEY_LEN-1:0] key,
    input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);
  localparam PAIR_LEN = KEY_LEN + DATA_LEN;
  wire [PAIR_LEN-1:0] pair_list[NR_KEY-1:0];
  wire [ KEY_LEN-1:0] key_list [NR_KEY-1:0];
  wire [DATA_LEN-1:0] data_list[NR_KEY-1:0];

  genvar n;
  generate
    for (n = 0; n < NR_KEY; n = n + 1) begin
      assign pair_list[n] = lut[PAIR_LEN*(n+1)-1-:PAIR_LEN];
      assign data_list[n] = pair_list[n][DATA_LEN-1:0];
      assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
    end
  endgenerate

  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;
  integer i;
  always @(*) begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
      hit = hit | (key == key_list[i]);
    end
    out = (hit ? lut_out : {DATA_LEN{1'b0}});
  end
endmodule
