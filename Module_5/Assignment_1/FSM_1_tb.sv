`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.04.2024 15:09:55
// Design Name: 
// Module Name: FSM_1_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for FSM_1 module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fsm_1_tb;

    // Signals
    reg clk = 0;
    reg areset = 1;
    
    reg [15:0] s_axis_tdata;
    reg s_axis_tvalid;
    wire s_axis_tready;
    reg s_axis_tlast;
    reg [7:0] s_axis_tkeep;
    
    wire [15:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    wire m_axis_tlast;
    wire [7:0] m_axis_tkeep;

    // Instantiate the FSM module
    fsm_1 fsm_inst (
        .clk(clk),
        .areset(areset),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tkeep(s_axis_tkeep),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tkeep(m_axis_tkeep)
    );

    // Clock generation
    always #5  clk = !clk;

    integer file;

    initial begin
        clk = 0;
        areset = 1;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 0;
        reset();
        fork
            axis_write(20);
            axi_ready_signal(20);
        join
    end

    task automatic reset;
    begin
        repeat (3) @(negedge clk);
        areset = ~areset;
    end
    endtask
  
    task automatic axis_write(input [15:0] n);
    begin
        file = $fopen("data_input.csv", "r");
        repeat (n) begin
            if (file == 0) begin
                $stop("Error in Opening file !!");
            end
            else begin
                @(negedge clk);
                $fscanf(file,"%h,%d,%b",s_axis_tdata,s_axis_tkeep,s_axis_tlast);
                s_axis_tvalid <= 1;
            end
        end
        s_axis_tvalid <= 0;
        $fclose(file);
    end
    endtask

    task automatic axi_ready_signal;
    input integer j;
    begin
        repeat (j) @(posedge clk) begin
            m_axis_tready <= 1; 
        end
        @(posedge clk) begin
            m_axis_tready <= 0; 
        end
    end
    endtask

endmodule
