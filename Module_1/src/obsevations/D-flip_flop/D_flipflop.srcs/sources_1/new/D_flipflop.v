`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2024 09:45:41
// Design Name: 
// Module Name: D_flipflop
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


module D_flipflop(
input clk,d,rst_n,
output reg q
    );
      //Here is reset is Asynchronous, You have include in sensitivity list
  
   always@(posedge clk ,negedge rst_n)
   begin
      if(!rst_n)
         q <= 1'b0;
      else
         q <= d;
   end
endmodule
