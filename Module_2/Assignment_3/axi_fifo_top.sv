module axis_fifo_top #(
 
    parameter DataWidth = 32,
    parameter Depth = 2048,  
    parameter ptrWidth  = $clog2(Depth))(

      input                  clk,
      input                  rst,

      input    [DataWidth-1   :0]   s_axis_tdata,
      input                  s_axis_tvalid,
      input                  s_axis_tlast,
      output                 s_axis_tready,

      output   [DataWidth-1   :0]   m_axis_tdata,
      output                 m_axis_tvalid,
      output                 m_axis_tlast,
      input                  m_axis_tready


    );

  logic [DataWidth-1   :0]   m_axis_tdata_1,m_axis_tdata_2,m_axis_tdata_reg;
  logic m_axis_tvalid_1,m_axis_tlast_1,s_axis_tready_1;
  logic m_axis_tvalid_2,m_axis_tlast_2,s_axis_tready_2;
  logic m_axis_tvalid_reg,m_axis_tlast_reg,s_axis_tready_reg;
  logic empty1,empty2,full1,full2;


  axis_fifo # (
              
              .DataWidth(DataWidth),
              .Depth(Depth)
            )
            axis_fifo_inst_1 (
              .clk(clk),
              .rst(rst),
              .s_axis_tdata(s_axis_tdata),
              .s_axis_tvalid(s_axis_tvalid),
              .s_axis_tlast(s_axis_tlast),
              .s_axis_tready(s_axis_tready),
              .m_axis_tdata(m_axis_tdata_1),
              .m_axis_tvalid(m_axis_tvalid_1),
              .m_axis_tlast(m_axis_tlast_1),
              .m_axis_tready(s_axis_tready_2),
              .full(full1),
              .empty(empty1)
            );

  always @(posedge clk)
  begin
    m_axis_tvalid_reg <= m_axis_tvalid_1;
    s_axis_tready_reg <= s_axis_tready_1;
  end

  assign m_axis_tvalid_2 = m_axis_tvalid_reg;
  assign m_axis_tlast_2  = m_axis_tlast_1;
  assign s_axis_tready_2 = s_axis_tready_reg;
  assign m_axis_tdata_2  = m_axis_tdata_1;

  axis_fifo # (
             
              .DataWidth(DataWidth),
              .Depth(Depth)
            )
            axis_fifo_inst_2 (
              .clk(clk),
              .rst(rst),
              .s_axis_tdata(m_axis_tdata_2),
              .s_axis_tvalid(m_axis_tvalid_2),
              .s_axis_tlast(m_axis_tlast_2),
              .s_axis_tready(s_axis_tready_1),
              .m_axis_tdata(m_axis_tdata),
              .m_axis_tvalid(m_axis_tvalid),
              .m_axis_tlast(m_axis_tlast),
              .m_axis_tready(m_axis_tready),
              .full(full2),
              .empty(empty2)
            );



endmodule