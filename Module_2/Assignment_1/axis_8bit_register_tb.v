`timescale 1ns / 1ps

module eight_bit_register_st_tb();

    // Define parameters
    parameter CLK_PERIOD = 10; // Clock period in ns
    
    // Declare signals
    reg clk = 0;
    reg reset = 1;
    
    reg [7:0] s_axis_tdata = 8'b0;
    reg s_axis_tvalid = 0;
    wire s_axis_tready;
    reg s_axis_tlast = 1;
    
    wire [7:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready ;//= 1;
    wire m_axis_tlast;
    
    // Instantiate the DUT
    eight_bit_register_st dut (
        .clk(clk),
        .reset(reset),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );
    
    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;
    
    // Test sequence
    initial begin
        // Reset
        reset = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 8'b0;
        #20;
        reset = 0;
        #20;
        
        // Test case 1: Send data
        s_axis_tvalid = 0;
        m_axis_tready = 0;
        s_axis_tdata = 8'b10101010; // Input data
        #100; // Wait for some cycles
        
        // Test case 2: Send more data
         s_axis_tvalid = 1;
        m_axis_tready = 1;
        s_axis_tdata = 8'b01010101; // Input data
        #100; // Wait for some cycles
        
          // Test case 3: Send more data
      //    s_axis_tlast = 1;
       m_axis_tready = 0;
        s_axis_tdata = 8'b01011001; // Input data
        #100; // Wait for some cycles
        
        // Test case 4: Stop sending data
        s_axis_tvalid = 0;
        s_axis_tdata = 8'b0;
        #100; // Wait for some cycles
        
        // Test case 4: Reset
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        // End simulation
        $finish;
    end

endmodule
