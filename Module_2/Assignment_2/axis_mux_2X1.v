
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream multiplexer
 */
module axis_mux #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 2,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8
  
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI inputs
     */
    input  wire [S_COUNT*DATA_WIDTH-1:0] s_axis_tdata,
    input  wire [S_COUNT-1:0]            s_axis_tvalid,
    output wire [S_COUNT-1:0]            s_axis_tready,
    input  wire [S_COUNT-1:0]            s_axis_tlast,


    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]         m_axis_tdata,
    output wire                          m_axis_tvalid,
    input  wire                          m_axis_tready,
    output wire                          m_axis_tlast,
 
    /*
     * Control
     */
    input  wire                          enable,
    input  wire [$clog2(S_COUNT)-1:0]    select
);

//parameter CL_S_COUNT = $clog2(S_COUNT);

reg [$clog2(S_COUNT)-1:0] select_reg = 2'd0, select_next;
reg frame_reg = 1'b0, frame_next;

reg [S_COUNT-1:0] s_axis_tready_reg = 0, s_axis_tready_next;

// internal datapath
reg  [DATA_WIDTH-1:0] m_axis_tdata_int;
reg                   m_axis_tvalid_int;
reg                   m_axis_tready_int_reg = 1'b0;
reg                   m_axis_tlast_int;
wire                  m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg;

// mux for incoming packet
wire [DATA_WIDTH-1:0] current_s_tdata  = s_axis_tdata[select_reg*DATA_WIDTH +: DATA_WIDTH];
wire                  current_s_tvalid = s_axis_tvalid[select_reg];
wire                  current_s_tready = s_axis_tready[select_reg];
wire                  current_s_tlast  = s_axis_tlast[select_reg];


always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    s_axis_tready_next = 0;

    if (current_s_tvalid & current_s_tready) begin
        // end of frame detection
        if (current_s_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (!frame_reg && enable && (s_axis_tvalid & (1 << select))) begin
        // start of frame, grab select value
        frame_next = 1'b1;
        select_next = select;
    end

    // generate ready signal on selected port
    s_axis_tready_next = (m_axis_tready_int_early && frame_next) << select_next;

    // pass through selected packet data
    m_axis_tdata_int  = current_s_tdata;

    m_axis_tvalid_int = current_s_tvalid && current_s_tready && frame_reg;
    m_axis_tlast_int  = current_s_tlast;

end

always @(posedge clk) begin
    select_reg <= select_next;
    frame_reg <= frame_next;
    s_axis_tready_reg <= s_axis_tready_next;

    if (rst) begin
        select_reg <= 0;
        frame_reg <= 1'b0;
        s_axis_tready_reg <= 0;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};

reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg  = 1'b0;



reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};

reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg  = 1'b0;


// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;


assign m_axis_tdata  = m_axis_tdata_reg;

assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = m_axis_tlast_reg;


// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_axis_tready_int_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (m_axis_tready_int_reg) begin
        // input is ready
        if (m_axis_tready || !m_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_axis_tready) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tready_int_reg <= m_axis_tready_int_early;
    temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;

    // datapath
    if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= m_axis_tdata_int;

        m_axis_tlast_reg <= m_axis_tlast_int;

    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
 
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
   
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
    
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
       
    end

    if (rst) begin
        m_axis_tvalid_reg <= 1'b0;
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= 1'b0;
    end
end

endmodule