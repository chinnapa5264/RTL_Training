`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2024 15:25:44
// Design Name: 
// Module Name: fsm_3_tb
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2024 11:27:00
// Design Name: 
// Module Name: fsm_2_tb
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


`timescale 1ns / 1ps

module fsm_3_tb;

    // Parameters
    localparam int DW_OUT  = 16;
    localparam int DW_IN      = 16;
    localparam int DW_USER = 8;
    localparam int Block = 40;
    parameter CLOCK_PERIOD    = 8;

    // Ports
    reg clock = 0;
    reg reset_n = 0;

    logic [DW_IN - 1:0] config_in_tdata=0;
    logic config_in_tvalid=0;
    logic config_out_tready=0;
    logic [DW_IN - 1:0] data_in_tdata = 0;
    logic [DW_USER - 1:0] data_in_tuser = 0;
    logic data_in_tvalid = 0;
    logic data_in_tlast = 0;
    logic data_in_tready;
    logic [Block - 1:0]packet_config;

    logic [DW_OUT - 1:0] data_out_tdata;
    logic [DW_USER - 1:0] data_out_tuser;
    logic data_out_tvalid;
    logic data_out_tlast;
    logic data_out_tready = 0;

    int count = 0;

   fsm_3 #(
        .DW_IN(DW_IN),
        .DW_OUT(DW_OUT),
        .DW_USER(DW_USER) 
    )
    wn_datapacker_dut (
        .clock (clock ),
        .reset_n (reset_n ),
        . config_in_tdata( config_in_tdata),
        .config_in_tvalid(config_in_tvalid),
        .config_out_tready(config_out_tready),
        .data_in_tdata (data_in_tdata ),
        .data_in_tuser (data_in_tuser ),
        .data_in_tlast (data_in_tlast ),
        .data_in_tvalid (data_in_tvalid ),
        .data_in_tready (data_in_tready ),
      
        .data_out_tdata (data_out_tdata ),
        .data_out_tuser (data_out_tuser ),
        .data_out_tlast (data_out_tlast ),
        .data_out_tvalid (data_out_tvalid ),
        .data_out_tready  ( data_out_tready)
      );

 // Clock generation
    always #5 clock = !clock;

    integer file;

    initial begin
        clock = 0;
        reset_n = 0;
        data_in_tdata = 0;
        data_in_tvalid = 0;
        data_in_tlast = 0;
        data_out_tready = 0;
        reset();
        fork
            axis_write(10);
            axi_ready_signal(10);
        join
    end

    task automatic reset;
    begin
        repeat (3) @(negedge clock);
        reset_n = ~reset_n;
    end
    endtask
  
    task automatic axis_write(input [15:0] n);
    begin
         @(negedge clock);begin
                 config_in_tdata<=40;
                 config_in_tvalid<=1;
                 end
        file = $fopen("stim_in.csv", "r");
        repeat (n) begin
            if (file == 0) begin
                $stop("Error in Opening file !!");
            end
            else begin
                @(negedge clock);
                 
                $fscanf(file,"%h,%d,%b",data_in_tdata,data_in_tuser,data_in_tlast);
                data_in_tvalid <= 1;
            end
        end
        data_in_tvalid <= 0;
        $fclose(file);
    end
    endtask

    task automatic axi_ready_signal;
    input integer j;
    begin
        repeat (j) @(posedge clock) begin
         config_out_tready<=1;
            data_out_tready <= 1; 
           
        end
        @(posedge clock) begin
        config_out_tready<=0;
           data_out_tready <= 0; 
        end
    end
    endtask


endmodule

