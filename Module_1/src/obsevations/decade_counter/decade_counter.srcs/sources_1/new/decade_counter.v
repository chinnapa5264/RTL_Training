`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2024 15:57:50
// Design Name: 
// Module Name: decade_counter
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


module decade_counter(
input clk,
input reset,
output reg [3:0]q
    );
    always@(posedge clk)
    begin 
    if(reset)
    q <= 4'd0;
    else if (q ==4'd9) 
        q<=4'd0;
    else
    q <= q+4'd1;
    end
endmodule
