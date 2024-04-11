`timescale 1ns / 1ps


/*
 * Multiplier - computes (a-d)*b +c;
 */



//using clk and reset
module axi_stream_multiply_add #(
    parameter DW = 8
  )(

    input                  clk,
    input                  rst,


      input     logic signed [DW-1   :0]   a,
      input     logic                      s_axis_valid_a,
      output    logic                      s_axis_ready_a,
      input     logic signed [DW-1   :0]   b,
      input     logic                      s_axis_valid_b,
      output    logic                      s_axis_ready_b,
      input     logic signed [DW-1   :0]   c,
      input     logic                      s_axis_valid_c,
      output    logic                      s_axis_ready_c,
      input     logic signed [DW-1   :0]   d,
      input     logic                      s_axis_valid_d,
      output    logic                      s_axis_ready_d,
      output    logic signed [DW-1   :0]   m_axis_tdata,
      output    logic                      m_axis_valid,
      input     logic                      m_axis_ready,
      output    logic                      overflow


  );


  logic signed [DW    :0] reg1,reg2;
  logic signed [2*DW-1:0] reg3;


  always @(posedge clk)
  begin
    if (rst)
    begin
    
      reg1 <= 0;
      reg2 <= 0;
      reg3 <= 0;
      m_axis_valid <= 0;

    end
    else 
    begin
if(s_axis_valid_a&s_axis_valid_b&s_axis_valid_c&s_axis_valid_d&s_axis_ready_a&s_axis_ready_b&s_axis_ready_c&s_axis_ready_d)
begin
      reg1 <= a-d;
      reg3 <= reg1*b;
      reg2 <= reg3+c;
      m_axis_valid <= s_axis_valid_a & s_axis_valid_b & s_axis_valid_c&s_axis_valid_d;
    end
    else begin
      reg1 <= 0;
      reg3 <= 0;
      reg2 <= 0;
      m_axis_valid <=0;
      end
    end
  end
  
   always @(posedge clk ) begin
        if (rst) begin
            s_axis_ready_a <= 0;
            s_axis_ready_b <= 0;
            s_axis_ready_c <= 0;
            s_axis_ready_d <= 0;
            end
            else  begin
            s_axis_ready_a <=  m_axis_ready;
            s_axis_ready_b <=  m_axis_ready;
            s_axis_ready_c <=  m_axis_ready;
            s_axis_ready_d <=  m_axis_ready;
            end
        end 
  
  assign m_axis_tdata=reg2[DW-1:0];
  assign overflow=reg2[DW];

endmodule