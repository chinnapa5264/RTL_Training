`timescale 1ns / 1ps

`include "downcounter.v"

module downcounter_tb;
reg     [7:0]   in;
reg             clk, latch, dec, div; 
wire    [7:0]   count;
wire            zero;

downcounter UUT(
    .in(in),
    .clk(clk),
    .latch(latch),
    .dec(dec),
    .div(div),
    .count(count),
    .zero(zero)
);

initial begin
    clk = 1'b0;
    forever #1 clk = ~clk; 
end


initial begin
    in= 8'd16; latch = 1'b1; dec = 1'b0; div = 1'b0;
    #2 in=8'd0;latch = 1'b0;
    #4.5  div = 1'b1;
    #6.5   div=1'b0;
    #5 $finish;
end
endmodule
