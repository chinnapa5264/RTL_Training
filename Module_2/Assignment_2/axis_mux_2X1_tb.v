`timescale 1ns / 1ps
`default_nettype none

module tb_axis_mux;
 parameter  Data_Width = 8;
    reg clk;
    reg reset;
    reg [ Data_Width-1:0] s_axis_tdata_1, s_axis_tdata_2;
    reg s_axis_tvalid_1, s_axis_tvalid_2;
    reg s_axis_tlast_1, s_axis_tlast_2;
    wire s_axis_tready_1, s_axis_tready_2;
    wire [ Data_Width-1:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    wire m_axis_tlast;
    reg select;

    // Instantiate the axis_mux module
    axis_mux #(
        .DATA_WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .s_axis_tdata_1(s_axis_tdata_1),
        .s_axis_tvalid_1(s_axis_tvalid_1),
        .s_axis_tready_1(s_axis_tready_1),
        .s_axis_tlast_1(s_axis_tlast_1),
        .s_axis_tdata_2(s_axis_tdata_2),
        .s_axis_tvalid_2(s_axis_tvalid_2),
        .s_axis_tready_2(s_axis_tready_2),
        .s_axis_tlast_2(s_axis_tlast_2),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .select(select)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
  initial
  begin
  clk=0;
  reset=1;
  s_axis_tdata_1=0;
  s_axis_tvalid_1=0;
  s_axis_tlast_1=0;
  s_axis_tdata_2=0;
  s_axis_tvalid_2=0;
  s_axis_tlast_2=0;
  m_axis_tready=0;
  reset_signal_task();
    
  fork
  axi_ready_signal(21);
//  #100
  axi_data_signal(20);
  axi_last_signal(22);
  join
   fork
  axi_ready_signal(21);
//  #100
  axi_data_signal(20);
  axi_last_signal(22);
  join
end


initial begin
    select=0;
    #100
    select=1;
    #80
    select=0;
    #60
    select=1;
    #60
    select=0;
    #200
    select=1;
    #200
    select=0;
    #100
    select=1;
    #80
    select=0;
    #60
    select=1;
   end
task automatic reset_signal_task;
    begin
    repeat (2) @(posedge clk);
      reset = ~reset;
    end
  endtask
  task automatic axi_last_signal;
input integer j;
begin

        repeat (j) begin
            @(posedge clk); 
            if(!select)begin
                if (s_axis_tdata_1==8) begin 
               s_axis_tlast_1 <= 1;
                 end
                 else begin
                   s_axis_tlast_1 <= 0;
              
                end
                
                end
                else begin
                if (s_axis_tdata_2==15) begin 
              s_axis_tlast_2 <= 1;
                end
                else begin
               s_axis_tlast_2 <= 0;
                end
                end
        end
        end
endtask
task automatic axi_data_signal;
input integer j;
begin

        repeat (j) begin
            @(posedge clk); 
            if(!select)begin
                if (!s_axis_tready_1) begin 
                 s_axis_tvalid_1 <= 0;
                 s_axis_tdata_1<=0;
                 end
                 else begin
                 s_axis_tvalid_1 <= 1;
                 s_axis_tdata_1 <= 2+s_axis_tdata_1;
              
                end
                
                end
                else begin
                if (!s_axis_tready_2) begin 
                 s_axis_tvalid_2 <= 0;
                 s_axis_tdata_2<=0;
                end
                else begin
                s_axis_tvalid_2 <= 1;
                s_axis_tdata_2 <= 3+s_axis_tdata_2;
                end
                end
        end
       @(posedge clk);
       //    s_axis_tlast_1 <= 1; 
            s_axis_tvalid_1 <=0;
            s_axis_tdata_1 <=0;
         //    s_axis_tlast_2 <= 1;
            s_axis_tvalid_2 <=0;
            s_axis_tdata_2 <=0;
end
endtask
 task automatic axi_ready_signal;
 input integer j;
        begin
        
           repeat (j) @(posedge clk) begin
               m_axis_tready <= 1; 
            end
            @(posedge clk);
            m_axis_tready <= 0;
    
        end
    endtask
 
  
endmodule
