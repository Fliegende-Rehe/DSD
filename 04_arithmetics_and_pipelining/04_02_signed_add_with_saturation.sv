//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task 2
//----------------------------------------------------------------------------

module signed_add_with_saturation(
    input signed [3:0] a, b,
    output reg signed [3:0] sum
);
    wire signed [4:0] extended_sum = a + b;

    always @(*) begin
        if (extended_sum > 7) begin
            sum = 7;
        end
        else if (extended_sum < -8) begin
            sum = -8; // Minimum negative value for 4-bit signed
        end
        else begin
            sum = extended_sum[3:0];
        end
    end
endmodule


//----------------------------------------------------------------------------
// Testbench
//----------------------------------------------------------------------------

module testbench;

  logic signed [3:0] a, b, sum;

  signed_add_with_saturation inst
    (.a (a), .b (b), .sum (sum));

  task test
    (
      input [3:0] t_a, t_b, t_sum
    );

    { a, b } = { t_a, t_b };

    # 1;

    $display ("TEST %d + %d = %d", a, b, sum);

    if (sum !== t_sum)
      begin
        $display ("%s FAIL: %d EXPECTED", `__FILE__, t_sum);
        $finish;
      end

  endtask

  initial
    begin
      test (  0,  0,  0);

      test (  1,  2,  3);
      test (  1, -2, -1);
      test ( -1,  2,  1);
      test ( -1, -2, -3);

      test (  4,  7,  7);
      test (  4, -7, -3);
      test ( -4,  7,  3);
      test ( -4, -7, -8);

      test (  3,  5,  7);
      test (  3, -5, -2);
      test ( -3,  5,  2);
      test ( -3, -5, -8);

      test (  3,  6,  7);
      test (  3, -6, -3);
      test ( -3,  6,  3);
      test ( -3, -6, -8);

      test (  2,  1,  3);
      test ( -2,  1, -1);
      test (  2, -1,  1);
      test ( -2, -1, -3);

      test (  7,  4,  7);
      test ( -7,  4, -3);
      test (  7, -4,  3);
      test ( -7, -4, -8);

      test (  5,  3,  7);
      test ( -5,  3, -2);
      test (  5, -3,  2);
      test ( -5, -3, -8);

      test (  6,  3,  7);
      test ( -6,  3, -3);
      test (  6, -3,  3);
      test ( -6, -3, -8);

      test (  1,  1,  2);
      test (  1, -1,  0);
      test ( -1,  1,  0);
      test ( -1, -1, -2);

      test (  4,  4,  7);
      test (  4, -4,  0);
      test ( -4,  4,  0);
      test ( -4, -4, -8);

      $display ("%s PASS", `__FILE__);
      $finish;
    end

endmodule
