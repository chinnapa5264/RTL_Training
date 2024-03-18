module sync_fifo#(
      parameter   DataWidth=31,
       parameter  Depth=2048,
       parameter  PtrWidth=$clog2(Depth)
         
  )(
    input  [DataWidth:0] datain,
    input  clk,
    input  rst,
    input  wr_en,
    input  rd_en,
    output  reg[DataWidth:0] data_out,
    output  full,
    output  empty
);


reg [DataWidth:0] fifo[Depth-1:0];
//reg [DataWidth-1:0]data_out_reg;
reg [PtrWidth:0] write_ptr,write_next;
reg [PtrWidth:0]read_ptr,read_next;
reg  [PtrWidth:0] counter;


initial  begin
integer i;
    for (i=0;i<Depth;i=i+1)begin
     fifo[i]=0;
     end
     data_out<=0;
        write_ptr <= 0;
        read_next<=0;
         read_ptr<= 0;
   end


always @(posedge clk ) begin
    if (rst) begin
        data_out <=0;
        write_ptr <= 0;
        read_next<=0;
        read_ptr<= 0;
       counter <=0;
    end
    else begin
        if (wr_en && !full) begin
            fifo[write_ptr] <= datain;
            write_ptr <= write_ptr + 1;
            counter <= counter+1;
            end
            else begin
             fifo[write_ptr] <= 0;
             end
           if (write_ptr == Depth) begin
           write_ptr <= 0;     
           counter <=0;       
         end
         if (rd_en && !empty) begin
           read_next <=  read_next+ 1;
            if ( read_next== Depth) 
              read_next<= 0;
              end
            if (rd_en && !empty) begin  
               read_ptr = read_next;
             data_out <= fifo[read_ptr];

        end
       end
     end 
         
  

assign full = (counter==Depth)?1:0;
assign empty = write_ptr==read_next?1:0;

endmodule
