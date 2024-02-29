`timescale 1ns / 1ps

module test_axis_mux;

// Parameters
parameter S_COUNT = 2;
parameter DATA_WIDTH = 8;
parameter integer CYCLE = 10; // Clock cycle in ns

// Inputs
reg clk = 0;
reg rst = 0;
reg m_axis_tready = 0;
reg [S_COUNT-1:0] s_axis_tvalid = 0;
reg [S_COUNT*DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [S_COUNT-1:0] s_axis_tlast = 0;
reg [1:0] select = 0; // Adjust size as needed for more streams
reg enable = 0;

// Outputs
wire [S_COUNT-1:0] s_axis_tready;
wire [DATA_WIDTH-1:0] m_axis_tdata;
wire m_axis_tvalid;
wire m_axis_tlast;

// Instantiate the Unit Under Test (UUT)
axis_mux #(
    .S_COUNT(S_COUNT),
    .DATA_WIDTH(DATA_WIDTH)
) uut (
    .clk(clk),
    .rst(rst),
    .m_axis_tready(m_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tready(s_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .enable(enable),
    .select(select)
);

// Clock generation
always #(CYCLE/2) clk = ~clk;

initial begin
    // Initialize Inputs
    rst = 1; m_axis_tready = 1; // Assume the downstream module is ready to accept data
    s_axis_tvalid = 0; s_axis_tdata = 0; s_axis_tlast = 0;
    select = 0; enable = 0;

    // Global reset
    #(CYCLE*2); rst = 0;

    // Test Case 1: Reset Check
    #(CYCLE*10); // Wait for reset propagation

    // Test Case 2: Stream Selection
    enable = 1; select = 0; // Enable and select stream 0
    s_axis_tvalid[0] = 1; s_axis_tdata[7:0] = 8'hAA; s_axis_tlast[0] = 1; // Data for stream 0
    select = 0;
    s_axis_tvalid[1] = 1; s_axis_tdata[15:8] = 8'h55; // Data for stream 1, should not be forwarded
    #(CYCLE); // Wait a cycle
    s_axis_tvalid = 0; s_axis_tlast = 0; // Clear valids

    // Test Case 3: Data Forwarding with Enable
    #(CYCLE*5);
    select = 1; // Switch to stream 1
    s_axis_tvalid[1] = 1; s_axis_tdata[15:8] = 8'hCC; s_axis_tlast[1] = 1; // Data for stream 1
    #(CYCLE); // Wait a cycle
    s_axis_tvalid = 1; s_axis_tlast = 0; // Clear valids

    // Test Case 4: TLast Forwarding
    enable = 1; select = 1;
    s_axis_tvalid[0] = 1; s_axis_tdata[7:0] = 8'hFF; s_axis_tlast[0] = 1; // Stream 0 with tlast
    #(CYCLE); // Wait a cycle
    s_axis_tvalid = 0; s_axis_tlast = 0; // Clear valids
    
    // More test cases can be added here...

    #(CYCLE*10); // Wait some time before finishing simulation
    $finish;
end
      
endmodule
