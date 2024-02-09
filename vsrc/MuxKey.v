`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:
// Design Name:
// Module Name: MuxKey
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


module MuxKey #(
    NR_KEY   = 2,
    KEY_LEN  = 1,
    DATA_LEN = 1
) (
    output reg [DATA_LEN-1:0] out,
    input [KEY_LEN-1:0] key,
    input [NR_KEY*DATA_LEN-1:0] inlines
);
  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;  //是否命中Key
  integer i;
  always @(*) begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == i[KEY_LEN-1:0]}} & inlines[DATA_LEN*(i+1)-1-:DATA_LEN]);
      hit = hit | (key == i[KEY_LEN-1:0]);
    end
    out = (hit ? lut_out : {DATA_LEN{1'b0}});
  end
endmodule
