`timescale 1ns / 1ns

module FPmul_tb;

  // Parameters
  localparam WI1 = 5;
  localparam WF1 = 14;
  localparam WI2 = 3;
  localparam WF2 = 14;
  localparam WIO = 8;
  localparam WFO = 14;

  // Ports
  reg signed [WI1 + WF1 - 1 : 0] A;
  reg signed [WI2 + WF2 - 1 : 0] B;
  reg overflow;
  reg underflow;
  reg signed [WIO + WFO - 1 : 0] multiply;

  // Instantiate FPadder module
  FPmul #(
    .WI1(WI1),
    .WF1(WF1),
    .WI2(WI2),
    .WF2(WF2),
    .WIO(WIO),
    .WFO(WFO)
  ) dut (
    .A(A),
    .B(B),
    .overflow(overflow),
    .underflow(underflow),
    .multiply(multiply)
  );

  // Define constants
  localparam ITERATIONS = 100;

  // Testbench
  initial begin
    integer file;
    real ref_A, ref_B, ref_C_mul, error_mul,error_mul_1, error_mul_abs;

    // Open file for writing results
    file = $fopen("5.14_mul_3.14_in_8.14.csv", "w");
    if (file == 0) $stop("Error in Opening file !!");

    // Random test generation loop
    repeat (ITERATIONS) begin
      // Generate random inputs
      A = $random;
      B = $random;

     
      ref_A = $signed(A ) /(2 ** WF1); 
      ref_B = $signed(B) / (2 ** WF2); 
      ref_C_mul = ref_A * ref_B;

      // Wait for some time for the output to settle
      #10;

      // Calculate error
      error_mul = ($signed(multiply )/(2 ** WFO)) - ref_C_mul;
      error_mul_1 = error_mul/(2 ** WFO);
      error_mul_abs = (error_mul_1 < 0) ? -error_mul_1 : error_mul_1;
    

      // Log results to file
      if (error_mul_abs > 1e-3) begin
        if (overflow) $fdisplay(file, "op err ----- Overflow has occurred! -----");
       // else if(underflow) $fdisplay(file, "op err ----- underflow has occurred! -----");
        else $fdisplay(file, "~~~~~ Output mismatch ~~~~~. Error = %f", error_mul_abs);
      end else begin
        if (overflow) $fdisplay(file, "----- Overflow has occurred! -----");
       //   else if(underflow) $fdisplay(file, "op err ----- underflow has occurred! -----");
        else $fdisplay(file, "Success. Precision = %f", error_mul_1);
      end
    end

    // Close file
    $fclose(file);
  end

endmodule








