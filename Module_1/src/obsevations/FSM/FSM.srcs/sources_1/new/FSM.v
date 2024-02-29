`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2024 16:06:12
// Design Name: 
// Module Name: FSM
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


module FSM(
    input clk,
    input reset,
    input in,
    output reg out
    );
    //reg out;
    
    reg B = 1'b0;
    reg A = 1'b1;
    reg ps , ns;
    always @(posedge clk) begin 
    if (reset)
    ps <= B;
    else
    ps <= ns;
    end
    
    always @(*)
    begin
    case(ps)
    B : ns <=in?B:A;
    A : ns <=in?A:B;
    endcase
    end
    always @(ps)
    case(ps)
    B: out =1;
    A: out =0;
    endcase
     
endmodule
