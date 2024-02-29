`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2024 10:10:15
// Design Name: 
// Module Name: counter
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


module t_ff(
output reg q,
input t, rst_n, clk);

always @ (posedge clk or negedge rst_n)
    if (!rst_n) q <= 1'b0;
    else if (t) q <= ~q;

endmodule

            //Standard counters are designed using either T or JK F/F.

module counter (
    output [2:0] q,
    input rst_n, clk);
    
    wire t2;
    
    t_ff ff0 ( q[0], 1'b1, rst_n, clk);
    t_ff ff1 ( q[1], q[0], rst_n, clk);
    t_ff ff2 ( q[2], t2,   rst_n, clk);
    and a1 (t2, q[0], q[1]);
    
endmodule