`timescale 1ns / 1ps

module eight_bit_register #(parameter Data_width = 8) (
    input wire clk,
    input wire reset,
    
    input wire  [Data_width-1:0] s_axis_tdata,
    input  wire s_axis_tvalid,
    output reg s_axis_tready,
    input wire s_axis_tlast,
    
    output reg [Data_width-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg m_axis_tlast
);

    reg [Data_width-1:0] reg_data=8'd0;
    reg ready_out;
    reg valid_out;
    reg tlast_out;
     
     always @(posedge clk ) begin
        if (reset) begin
             tlast_out <= 1'b0;
              end 
              else begin
              tlast_out <= s_axis_tlast;
 
              end 
        end
        
    always @(posedge clk ) begin
        if (reset) begin
           valid_out<=1'b0;
        end 
        else  begin
           valid_out <= s_axis_tvalid;    
                
        end
      
        end
        
    always @(posedge clk ) begin
        if (reset) begin
            reg_data <= 8'b0;
        end 
        else if (s_axis_tready && s_axis_tvalid) begin
            reg_data <= s_axis_tdata;            
        end
        else 
           reg_data <= 0;
        end

 
  always @(posedge clk ) begin
        if (reset) begin
            ready_out <= 8'b0;
            end
            else 
            ready_out <= m_axis_tready;
        end
 
always @(*) begin
    assign s_axis_tready = ready_out ;
    assign m_axis_tdata = reg_data;
    assign m_axis_tvalid = valid_out;
    assign m_axis_tlast = tlast_out;
    end

endmodule

