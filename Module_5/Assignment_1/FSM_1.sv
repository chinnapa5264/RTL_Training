`timescale 1ns / 1ps



 module fsm_1 (
    input   wire          clk,
    input   wire          areset,
    
    input   wire [15:0]   s_axis_tdata,
    input   wire          s_axis_tvalid,
    output  reg          s_axis_tready,
    input   wire          s_axis_tlast,
    input   wire [7:0]    s_axis_tkeep,
    
    output  reg  [15:0]   m_axis_tdata,
    output  reg           m_axis_tvalid,
    input   wire          m_axis_tready,
    output  reg           m_axis_tlast,
    output  reg [7:0]    m_axis_tkeep
);

parameter DATA_WIDTH = 16;

localparam STATE_Initial = 3'd0,
           STATE_1       = 3'd1,
           STATE_2       = 3'd2,
           STATE_3       = 3'd3,
           STATE_4       = 3'd4;

reg [3:0] CurrentState, NextState;
reg [15:0] mem, mem_s;
reg [15:0]mem_1,mem_2,mem_3;
reg [7:0]  t_keep_out=0,t_keep_out_reg=0;
reg m_axis_tlast_reg;

always @(posedge clk or posedge areset) begin
    if (areset) begin
        CurrentState <= STATE_Initial;
    end else begin
        CurrentState <= NextState;
    end
end

always @* begin
    NextState = CurrentState;
    case (CurrentState)
        STATE_Initial: begin
            if (s_axis_tvalid) begin
            case(s_axis_tkeep)
             0:NextState = STATE_Initial;
             4:NextState = STATE_1;
             8:NextState = STATE_1;
             12:NextState = STATE_1;
             16:NextState = STATE_2;
            endcase
            end
        end
        STATE_1: begin
            if ((m_axis_tready == 1'b1) | (s_axis_tvalid && s_axis_tready)) begin
              case(s_axis_tkeep)
             0:NextState = STATE_Initial;
             4:NextState = STATE_1;
             8:NextState = STATE_1;
             12:NextState = STATE_1;
             16:NextState = STATE_3;
            endcase
            end
        end
        STATE_2: begin
            if (m_axis_tready) begin
                 case(s_axis_tkeep)
             0:NextState = STATE_Initial;
             4:NextState = STATE_1;
             8:NextState = STATE_1;
             12:NextState = STATE_1;
             16:NextState = STATE_Initial;
            endcase
            end       
        end  
          STATE_3: begin
            if (m_axis_tready) begin
                 case(s_axis_tkeep)
             0:NextState = STATE_Initial;
             4:NextState = STATE_1;
             8:NextState = STATE_1;
             12:NextState = STATE_4;
             16:NextState = STATE_3;
            endcase
            end       
        end   
          STATE_4: begin
            if (m_axis_tready) begin
                 case(s_axis_tkeep)
             0:NextState = STATE_4;
             4:NextState = STATE_1;
             8:NextState = STATE_1;
             12:NextState = STATE_1;
             16:NextState = STATE_3;
            endcase
            end       
        end     
    endcase
end




always @(posedge clk) begin
    if (areset) begin
        s_axis_tready <= 1'b0;
    end else begin
        case (NextState)
            STATE_1, STATE_2,STATE_3,STATE_4: begin
                s_axis_tready <= 1'b1;
            end
            default: begin
                s_axis_tready <= 1'b0;
            end
        endcase
    end
end



always @(posedge clk) begin
    if (areset) begin
        mem_s <= 16'h0;
         t_keep_out<=0;
    end else begin
        case (NextState)
            STATE_Initial: begin
                mem_s <= 0;
                t_keep_out<=0;
            end
            STATE_1: begin
              
                   if(s_axis_tkeep<16&& t_keep_out==16)
                   begin
                    case(s_axis_tkeep)
                    0: mem_s <= 0 ;
                    4: mem_s <= (s_axis_tdata << 12) ;
                    8: mem_s <= (s_axis_tdata << 8) ;
                    12: mem_s <= (s_axis_tdata << 4) ;
            
                endcase
                  t_keep_out<=s_axis_tkeep+ t_keep_out;

                end
            if(s_axis_tkeep<16&& t_keep_out>16)
                   begin
                    case(s_axis_tkeep)
                    0: mem_s <= 0 ;
                    4: mem_s <= (s_axis_tdata<<12)+(mem>>12) ;
                    8: mem_s <= (s_axis_tdata <<8)+(mem>>8)  ;
                    12: mem_s <= (s_axis_tdata<<4 )+(mem>>4)  ;
            
                endcase
                  t_keep_out<=s_axis_tkeep+ t_keep_out-16;

                end
                
          end
       
            STATE_2: begin
                  if(s_axis_tkeep==16)
                   begin
                  mem_s <=  s_axis_tdata  ;
                  t_keep_out<=s_axis_tkeep;
                end
            end
            
              STATE_3: begin
              
                   if(s_axis_tkeep==16&& t_keep_out>16)
                   begin
                    case(s_axis_tkeep)
                    0: mem_s <= 0 ;
                    4: mem_s <= (s_axis_tdata << 12)+(mem>>12) ;
                    8: mem_s <= (s_axis_tdata << 8)+(mem>>8) ;
                    12: mem_s <= (s_axis_tdata<<4)+(mem_2>>12)  ;
                    16:mem_s <= (s_axis_tdata<<(t_keep_out-16))+(mem>>(t_keep_out-16));
            
                endcase
                  t_keep_out<=s_axis_tkeep;
                  mem_1<=s_axis_tdata;
                
                end
                
                end
              STATE_4: begin
              
                   if(s_axis_tkeep<16&& t_keep_out==16)
                   begin
                    case(s_axis_tkeep)
                    0: mem_s <= (mem_2>>12) ;
                    4: mem_s <= (s_axis_tdata << 12)+(mem>>12) ;
                    8: mem_s <= (s_axis_tdata << 8)+(mem>>8) ;
                    12: mem_s <= (s_axis_tdata<<(s_axis_tkeep-4))+(mem_1>>(s_axis_tkeep-4)) ;
                   16:mem_s <= (s_axis_tdata<<(t_keep_out-16))+(mem>>(t_keep_out-16));
            
                endcase
                  t_keep_out<=s_axis_tkeep+4;
                  mem_1<=s_axis_tdata;
                  mem_2<=s_axis_tdata<<4;
                end
                
                end
        endcase
    end   
  
end
always @(posedge clk)begin
m_axis_tlast_reg  <=((NextState == STATE_2)||(NextState == STATE_4)||(NextState == STATE_1)) ? s_axis_tlast : 1'b0;
mem_3 <=mem;
t_keep_out_reg<=t_keep_out;
end
assign mem=mem_s;
assign m_axis_tdata  =m_axis_tvalid? mem_s:mem_3;
assign m_axis_tvalid =(CurrentState==STATE_4||(t_keep_out==16)) && (m_axis_tready);
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tkeep  = m_axis_tvalid?t_keep_out:t_keep_out_reg;

endmodule





