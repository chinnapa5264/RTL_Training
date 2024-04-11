`timescale 1ns / 1ps

module packet_data #(
    parameter Data_width = 8,
    parameter Depth = 64)(

      input                         clk,
      input                         rst,

      input           [Data_width-1   :0]   s_axis_tdata,
      input                         s_axis_tvalid,
      input                         s_axis_tlast,
      output    logic               s_axis_tready,
      input            [Data_width+Data_width-1 :0] packet_config,
      output    logic  [Data_width-1   :0]  m_axis_tdata,
      output    logic               m_axis_tvalid,
      output    logic               m_axis_tlast,
      input                         m_axis_tready,
      output    logic                full,
      output    logic                empty
    );

  reg [Data_width-1:0] mem_1 [Depth-1:0];
  reg [Data_width-1:0] mem_2 [Depth-1:0];
  reg mem_3 [Depth-1:0];
  reg [Data_width-1:0] k,len,wr_ptr,rd_ptr,wr_ptr2;
 
 // reg flag=0;


  assign {k,len} = packet_config;
  assign full = wr_ptr==Depth?1:0;
  assign empty = wr_ptr==0?1:0;
  integer i;


  initial
  begin
    for(i = 0; i < Depth; i = i + 1)
    begin
      mem_1[i] = 0;
      mem_2[i] = 0;
      mem_3[i] = 0;
    end
  end


  always@(posedge clk)
  begin
    if (rst)
    begin
      s_axis_tready <=0;
    end
    else
    begin
      s_axis_tready <=1;
    end
  end


  always @(posedge clk)
  begin
    if (rst)
    begin
      wr_ptr <= 0;
    end
    else
    begin
      if (s_axis_tvalid && s_axis_tready&&~full)
      begin
        mem_1[wr_ptr] <= s_axis_tdata;
        mem_3[wr_ptr] <= s_axis_tlast;
        if (wr_ptr>len-1-k)
        begin
          mem_2[wr_ptr2]<=s_axis_tdata;
          wr_ptr2<=wr_ptr2+1;
        end
        else
        begin
          wr_ptr2<=0;
        end
        wr_ptr <= wr_ptr + 1;
       // flag<=1;
        if (s_axis_tlast)
        begin
          wr_ptr <= 0;
        end
      end
    end
  end

  always@(posedge clk)
  begin
    if (rst)
    begin
      rd_ptr<=0;
      m_axis_tdata<=0;
      m_axis_tlast<=0;
      m_axis_tvalid<=0;
    end
    else
    begin
      if (m_axis_tready&&~empty )
      begin
        m_axis_tvalid<=1;
        m_axis_tdata<=mem_1[rd_ptr]+mem_2[rd_ptr];
        m_axis_tlast<=mem_3[rd_ptr];
        rd_ptr<=rd_ptr+1; 
        if (rd_ptr==len-1)begin
               rd_ptr<=0;
        end     
      end 
      else begin
        m_axis_tvalid<=0;
        m_axis_tdata<=0;
        end
    end
  end
 endmodule