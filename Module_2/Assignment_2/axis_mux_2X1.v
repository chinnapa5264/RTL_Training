
`timescale 1ns / 1ps


/*
 * AXI4-Stream multiplexer
 */
module axis_mux #
(
    // Number of AXI stream inputs
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8
  
)
(
    input                            clk,
    input                            reset,

    /*
     * AXI inputs
     */
    input    [DATA_WIDTH-1:0] s_axis_tdata_1,
    input                     s_axis_tvalid_1,
    output                    s_axis_tready_1,
    input                     s_axis_tlast_1,
    
    input   [DATA_WIDTH-1:0] s_axis_tdata_2,
    input                    s_axis_tvalid_2,
    output                    s_axis_tready_2,
    input                    s_axis_tlast_2,


    /*
     * AXI output
     */
    output   [DATA_WIDTH-1:0]         m_axis_tdata,
    output                            m_axis_tvalid,
    input                           m_axis_tready,
    output                            m_axis_tlast,
 
    /*
     * Control
     */

    input   wire                       select
);
    
    reg [DATA_WIDTH-1:0] reg_data=8'd0;
    reg ready_out_1;
    reg ready_out_2;
    reg valid_out;
    reg tlast_out;



        
 always @(posedge clk )
  begin
    if (reset)
    begin
     reg_data <= 8'b0;
     valid_out<=1'b0;
     tlast_out <=0;
    end
    else
    begin
      if(!select)          
      begin
        if ( s_axis_tready_1 && s_axis_tvalid_1 )
        begin
          reg_data <= s_axis_tdata_1;
          valid_out <= s_axis_tvalid_1;
            tlast_out <= s_axis_tlast_1;
        end
        else
        begin
           reg_data <= 0;
           valid_out <=0;
	   tlast_out <=0;
        end

      end
      else
      begin
        if ( s_axis_tready_2 && s_axis_tvalid_2 )
        begin
          reg_data <= s_axis_tdata_2;
          valid_out <= s_axis_tvalid_2;
          tlast_out <= s_axis_tlast_2;
        end
        else
        begin
         reg_data <= 0;
         valid_out <=0;
         tlast_out <=0;
        end
      end
    end
  end


  always @(posedge clk ) begin
        if (reset) begin
            ready_out_1 <= 8'b0;
            ready_out_2 <= 8'b0;
            end
            else 
            begin 
            if(!select) begin
            ready_out_1 <= m_axis_tready;
            ready_out_2 <= 0; 
            end          
            else begin
            ready_out_1 <=0;
            ready_out_2 <= m_axis_tready;
            end
            end
            
        end
        
        
 
    assign s_axis_tready_1 = ready_out_1 ;
    assign s_axis_tready_2 = ready_out_2 ;
    assign m_axis_tdata = reg_data;
    assign m_axis_tvalid = valid_out;
    assign m_axis_tlast = tlast_out;
    

endmodule