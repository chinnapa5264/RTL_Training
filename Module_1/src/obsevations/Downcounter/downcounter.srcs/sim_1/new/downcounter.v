`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2022 16:00:09
// Design Name: 
// Module Name: downcounter
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

module downcounter(
    // Inputs
    in,
    clk,
    latch,
    dec,
    div,
    // Outputs
    count,
    zero
);

// Inputs
input   wire    [7:0]   in;
input   wire            clk;
input   wire            latch;
input   wire            dec;
input   wire            div;
// Outputs
output  wire            zero;
// Internal
output  reg     [7:0]   count;

always @(posedge clk)
begin
    if(latch)
        count <= in;
    else if(dec)
        count <= count - 1;
    else if(div)
        count <= count >> 1;
end

assign zero = (count == 0);

endmodule
