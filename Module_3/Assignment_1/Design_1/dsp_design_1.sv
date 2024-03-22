`timescale 1ns / 1ps

/* design with no clk and reset 
design without axi stream interface */
module dsp_slice #(parameter data_width=8)(
    input [data_width-1:0] a,
    input [data_width-1:0] b,
    input [data_width-1:0] c,
    output reg [(2*data_width)-1:0] result
);
                                                                           
always @(*)
begin
    result = ((a*b)+c);
end



endmodule
