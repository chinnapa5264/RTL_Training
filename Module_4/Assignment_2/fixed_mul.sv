`timescale 1ns / 1ns


module FPmul
#(parameter  WI1 = 5, 
             WF1 = 14,
             WI2 = 5,
             WF2 = 14,
             WIO = 10,
             WFO = 28,
             intL = WI1 + WI2,
             fracL = WF1 + WF2)

   (
    input signed[(WI1+WF1-1):0] A,
    input signed[(WI2+WF2-1):0] B,
    output signed[(WIO+WFO-1):0] multiply,
    output overflow,
    output underflow
   );

wire [(intL+fracL):0] tempmult;

reg sign;
reg  [(WIO-1) : 0] outI;
reg  [(WFO-1) : 0] outF;


assign tempmult = $signed(A)*$signed(B);

//------------------------------------------truncation-------------------------------------------------//
//---------------------------------adjusting bitwidth of fractional part-------------------------------//
always @* begin
  if (WFO >= fracL)begin
    outF = {tempmult[fracL-1:0],{(WFO-fracL){1'b0}}};
  end
  else begin
    outF = tempmult[(fracL-1):(fracL-WFO)];
  end
end


always @ * begin
if ((A[WI1+WF1-1]== B[WI2+WF2-1]))
 sign = 0;//tempout[WIO+WFO-1];
else if((!A[WI1+WF1-1]== B[WI2+WF2-1]|A[WI1+WF1-1]==! B[WI2+WF2-1]))
 sign = 1;//tempout[bigger_int+bigger_Frac-1]; 
else 
 sign=0;
end
//---------------------adjusting bitwidth of Integer part and check if overflow occurs-----------------//
// If overflow occurs indicate by making overflow flag = 1



 
assign overflow = (intL>=WIO)?tempmult[intL+fracL]? (~&tempmult[intL+fracL: fracL+WIO-1] == tempmult[intL+fracL ]):(|tempmult[intL+fracL-1:fracL+WIO-1]):0;                   

                 
 assign underflow = (WFO==fracL)?0:|tempmult[fracL-WFO-1:0];
                

always @* begin
  if (WIO >= intL+1)begin
    outI = {{(WIO-intL){sign}},tempmult[WIO+fracL:fracL]};

  end
  else begin
    if (WIO == 1)begin
      outI = tempmult[intL+fracL-1];
     
    end  
    else begin
      outI = {sign,tempmult[WIO+fracL-1:fracL]};
      
    end
  end
end

assign multiply ={outI,outF};

endmodule
