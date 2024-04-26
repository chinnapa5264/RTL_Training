`timescale 1ns / 1ns

module FPadder_tb;

  // Parameters
  localparam WI1 = 3;
  localparam WF1 = 14;
  localparam WI2 = 3;
  localparam WF2 = 14;
  localparam WIO = 2;
  localparam WFO = 14;

  // Ports
  reg signed [WI1 + WF1 - 1 : 0] A;
  reg signed [WI2 + WF2 - 1 : 0] B;
  reg overflow;
  reg signed [WIO + WFO - 1 : 0] out;

  // Instantiate FPadder module
  FPadder #(
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
    .out(out)
  );

  // Define constants
  localparam ITERATIONS = 100;

  // Testbench
  initial begin
    integer file;
    real ref_A, ref_B, ref_C_add, ref_out,error_add,error_add_1, error_add_abs;

    // Open file for writing results
    file = $fopen("3.14_add_3_14_in_2.14.csv", "w");
    if (file == 0) $stop("Error in Opening file !!");

    // Random test generation loop
    repeat (ITERATIONS) begin
      // Generate random inputs
      A = $random;
      B = $random;

      ref_A = $signed(A ) /(2 ** WF1); // Convert fixed-point to floating-point
      ref_B = $signed(B) / (2 ** WF2); // Convert fixed-point to floating-point
      ref_C_add = ref_A + ref_B;

      // Wait for some time for the output to settle
      #10;

      // Calculate error
      error_add = ($signed(out )/(2 ** WFO)) - ref_C_add;
      error_add_1 = error_add/(2 ** WFO);
      error_add_abs = (error_add_1 < 0) ? -error_add_1 : error_add_1;
    

      // Log results to file
      if (error_add_abs > 1e-3) begin
        if (overflow) $fdisplay(file, "op err ----- Overflow has occurred! -----");
        else $fdisplay(file, "~~~~~ Output mismatch ~~~~~. Error = %f", error_add_abs);
      end else begin
        if (overflow) $fdisplay(file, "----- Overflow has occurred! -----");
        else $fdisplay(file, "Success. Precision = %f", error_add_1);
      end
    end


    // Close file
    $fclose(file);
  end

endmodule



