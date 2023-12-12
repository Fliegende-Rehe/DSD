//----------------------------------------------------------------------------
// Task 4
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output reg          res_vld,
    output reg  [31:0]  res,

    // isqrt interface
    output reg          isqrt_x_vld,
    output reg  [31:0]  isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    typedef enum int {IDLE, CALC_A, CALC_B, CALC_C, WAIT_A, WAIT_B, WAIT_C, DONE} state_t;
    state_t state, next_state;

    reg [31:0] sum;
    reg [31:0] sqrt_a, sqrt_b, sqrt_c;

    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        isqrt_x_vld = 0;
        res_vld = 0;

        case (state)
            IDLE: begin
                if (arg_vld)
                    next_state = CALC_A;
            end
            CALC_A: begin
                isqrt_x = a;
                isqrt_x_vld = 1;
                next_state = WAIT_A;
            end
            WAIT_A: begin
                if (isqrt_y_vld) begin
                    sqrt_a = isqrt_y;
                    next_state = CALC_B;
                end
            end
            CALC_B: begin
                isqrt_x = b;
                isqrt_x_vld = 1;
                next_state = WAIT_B;
            end
            WAIT_B: begin
                if (isqrt_y_vld) begin
                    sqrt_b = isqrt_y;
                    next_state = CALC_C;
                end
            end
            CALC_C: begin
                isqrt_x = c;
                isqrt_x_vld = 1;
                next_state = WAIT_C;
            end
            WAIT_C: begin
                if (isqrt_y_vld) begin
                    sqrt_c = isqrt_y;
                    sum = sqrt_a + sqrt_b + sqrt_c;
                    next_state = DONE;
                end
            end
            DONE: begin
                res = sum;
                res_vld = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule
