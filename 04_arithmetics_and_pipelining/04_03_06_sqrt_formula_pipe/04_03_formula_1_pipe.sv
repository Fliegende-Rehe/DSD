//----------------------------------------------------------------------------
// Task 3
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    wire [15:0] sqrt_a, sqrt_b, sqrt_c;
    wire valid_a, valid_b, valid_c;

    isqrt #(.n_pipe_stages(16)) isqrt_a
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(a),
        .y_vld(valid_a),
        .y(sqrt_a)
    );

    isqrt #(.n_pipe_stages(16)) isqrt_b
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(b),
        .y_vld(valid_b),
        .y(sqrt_b)
    );

    isqrt #(.n_pipe_stages(16)) isqrt_c
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(valid_c),
        .y(sqrt_c)
    );

    reg [31:0] sum;
    reg sum_valid;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            sum <= 0;
            sum_valid <= 0;
        end
        else if (valid_a && valid_b && valid_c)
        begin
            sum <= sqrt_a + sqrt_b + sqrt_c;
            sum_valid <= 1;
        end
        else
        begin
            sum_valid <= 0;
        end
    end

    assign res = sum;
    assign res_vld = sum_valid;

endmodule
