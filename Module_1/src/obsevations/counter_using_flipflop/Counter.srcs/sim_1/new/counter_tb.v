`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2024 10:12:36
// Design Name: 
// Module Name: counter_tb
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


module tb_counter_3bit;
    reg clk,rst_n;
    wire [2:0] q;
    reg [2:0] count;
    
    counter CNTR (.clk(clk),.rst_n(rst_n),.q(q));
    
    initial begin
        clk <= 1'b0;
        forever #5 clk <= ~ clk;
    end

    initial
    begin
         rst_n <= 0;
         @(posedge clk);
         @(negedge clk);
         rst_n <= 1;
         repeat (10)   @(posedge clk);
         $finish;
    end
    
    //Below always block represents the 3-bit counter in behavior style.
    //Here it is used to generate reference output
    always @(posedge clk or negedge rst_n) begin
         if (!rst_n) 
             count <= 0;
         else
             count <= (count + 1);
    end
    
    always @( q ) scoreboard(q,count);
    
    //Below task is used to compare reference and generated output. Similar to score board //in SV Test bench
    
    task scoreboard;
    input [2:0]count;
    input [2:0] q;
    begin
       if (count == q)
           $display ("time =%4t q = %3b count = %b match!-:)",
                                  $time, q, count);
       else
           $display ("time =%4t q = %3b count = %b <-- no match",
                                 $time, q, count);
    end
    endtask

endmodule
