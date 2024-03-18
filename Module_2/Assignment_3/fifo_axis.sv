`timescale 1ns / 1ps

module axis_fifo #(
    parameter DataWidth= 32,
    parameter Depth  = 2048,
   parameter PtrWidth  = $clog2(Depth))(

      input                  clk,
      input                  rst,

      input    [DataWidth-1   :0]   s_axis_tdata,
      input                  s_axis_tvalid,
      input                  s_axis_tlast,
      output                 s_axis_tready,

      output   [DataWidth-1   :0]   m_axis_tdata,
      output                m_axis_tvalid,
      output                 m_axis_tlast,
      input                  m_axis_tready,
      output                 full,
      output                 empty
    );

 logic [DataWidth:0] s_axis_tdata_reg;
 logic [DataWidth:0] m_axis_tdata_reg;
 
 

  logic ready_out;
  logic valid_out;
 

  sync_fifo #(
         .DataWidth(DataWidth),
         .Depth(Depth),
         .PtrWidth(PtrWidth)
         
  ) fifo_inst(
         .clk(clk),
         .rst(rst),
         .wr_en(wr_en),
         .datain(s_axis_tdata_reg),
         .rd_en(rd_en),
         .data_out( m_axis_tdata_reg),
         .full(full),
         .empty(empty)
       );

  always @(*)
  begin
    if (rst || full)begin
     ready_out <=0;
   
     end
    else begin
      ready_out <=1;

      end
  end


always@(posedge clk)
begin
if(rst) begin
valid_out<=0;

end
else begin
if(rd_en && ~empty)
 valid_out <=1;
 else 
 valid_out <=0;
 end
end
 
  assign s_axis_tready= ready_out;
  assign m_axis_tvalid = valid_out;//(enb && ~empty)?1:0;
  assign wr_en = s_axis_tvalid && s_axis_tready ;
  assign rd_en = (m_axis_tready)?1:0;
  assign s_axis_tdata_reg = wr_en?{s_axis_tlast,s_axis_tdata}:0;
  assign {m_axis_tlast,m_axis_tdata} = rd_en?m_axis_tdata_reg:0;


 

endmodule