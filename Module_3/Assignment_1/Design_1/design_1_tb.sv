`timescale 1ns / 1ps
module tb_dsp_slice;

    // Inputs
    parameter  data_width =8;
    reg [data_width -1:0] a;
    reg [data_width -1:0] b;
    reg [data_width -1:0] c;
    // Outputs
    wire [(data_width*2)-1:0] result;

    // Instantiate the DUT (Design Under Test)
    dsp_slice  #(.data_width(data_width))dut(
        .a(a),
        .b(b),
        .c(c),
        .result(result)
    );

    // Stimulus
    initial begin
        // Test case 1: Multiply 10 by 5
        a = 10;
        b = 5;
        c=1;
        #10; // Wait for some time for the result to stabilize

        // Test case 2: Multiply 255 by 255
        a = 25;
        b = 10;
        c=5;
        #10;
        a=50;
        b=10;
        #10;
        b=5;
        #10;
        a=0;
        #10;
        b=0;
        c=0;

        // Add more test cases here as needed

        // End the simulation
        $finish;
    end

endmodule
