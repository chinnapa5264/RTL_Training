`timescale 1ns / 1ps

module downcounter(
  
// Inputs
input   wire    [7:0]   in,
input   wire            clk,
input   wire            latch,
input   wire            dec,
input   wire            div,
// Outputs
output  wire            zero,
// Internal
output  reg     [7:0]   count
);

always @(posedge clk)
begin
    if(latch)
        count <= in;
    else if(dec)
        count <= (count==8'd0)?8'd0:count - 1;
    else if(div)
        count <= count >> 1;
end

assign zero = (count == 0);

endmodule
