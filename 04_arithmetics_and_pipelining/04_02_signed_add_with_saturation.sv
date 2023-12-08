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
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output reg [3:0] sum
);
  wire signed [5:0] full_sum = {a[3], a[3], a} + {b[3], b[3], b};

  always @* begin
    if (full_sum > 4'b0111)
      sum = 4'b0111;
    else if (full_sum < 4'b1000)
      sum = 4'b1000;
    else
      sum = full_sum[3:0];
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
