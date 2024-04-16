
`timescale 1ns / 1ps
/*****Pattern given from input side with mask.******/
module test_dsp  #(parameter width_in1=24,parameter width_in2=17,parameter width_out=42)(
    input clk_i,
    input signed [width_in1:0] a_i,
    input signed [width_in2:0] b_i,
    input signed [width_out:0] pd_pattern1,
    output  signed [width_out:0] c_o,
    output reg ones_o
);

reg signed [width_out:0] ab;


// Pattern detect mask
reg [width_in1:0] a_reg;
reg [width_in2:0] b_reg;
reg [width_out:0] pd_pattern;
wire [width_out:0]mask;
wire mask1=1;
//assign pd_pattern = 43'b00000000000000000000000000000000000011111111111111111110011111011101111111;
assign mask = 43'b1111111111111111111111111111111111111111111;

always @(posedge clk_i) begin
a_reg<= a_i;
b_reg<=b_i;
pd_pattern <= pd_pattern1;
end

always @(posedge clk_i) begin
      
    ab <= a_reg * b_reg; // Perform the multiplication

    // Pattern detect logic
    if (ab == pd_pattern||mask) begin
        ones_o <= 1'b1; // Set ones_o if pattern detected
    end else begin
        ones_o <= 1'b0; // Reset ones_o if pattern not detected
    end
end

assign c_o = ab; // Output the multiplication result

endmodule

/*** Pattern given inside the code through assign with some value.***/
/*module test_dsp #(parameter width_in1 = 17, parameter width_in2 = 24, parameter width_out = 42)(
    input clk_i,
    input signed [width_in1-1:0] a_i,
    input signed [width_in2-1:0] b_i,
    output reg ones_o
);

reg signed [width_out-1:0] ab;

// Define the "pin" pattern
parameter [width_out-1:0] pd_pattern = 43'b011100100110100101100111;

always @(posedge clk_i) begin
    ab <= a_i * b_i; // Perform the multiplication

    // Pattern detect logic
    if (ab == pd_pattern) begin
        ones_o <= 1'b1; // Set ones_o if pattern detected
    end else begin
        ones_o <= 1'b0; // Reset ones_o if pattern not detected
    end
end

endmodule*/
/****	Pattern detect pin example.****/
/*
module test_dsp(
    input clk_i,
    input signed [24:0] a_i,
    input signed [17:0] b_i,
    output reg ones_o
);

reg signed [42:0] ab;

// Define the "pin" pattern
parameter [42:0] pd_pattern = 48'b011100100110100101100111;

always @(posedge clk_i) begin
    ab <= a_i * b_i; // Perform the multiplication

    // Pattern detect logic
    if (ab == pd_pattern) begin
        ones_o <= 1'b1; // Set ones_o if pattern detected
    end else begin
        ones_o <= 1'b0; // Reset ones_o if pattern not detected
    end
end

endmodule*/

