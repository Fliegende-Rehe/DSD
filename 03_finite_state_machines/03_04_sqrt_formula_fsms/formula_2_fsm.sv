//----------------------------------------------------------------------------
// Task 5
//----------------------------------------------------------------------------

module formula_2_fsm (
    input               clk,
    input               rst,
    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,
    output reg          res_vld,
    output reg   [31:0] res,
    output reg          isqrt_x_vld,
    output reg   [31:0] isqrt_x,
    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // State declaration
    typedef enum int {IDLE, CALC_ISQRT_C, CALC_ISQRT_B_PLUS_C, CALC_ISQRT_A_PLUS_B, DONE} state_t;
    state_t state, next_state;

    // Intermediate result registers
    reg [31:0] result_b_plus_c;
    reg [31:0] result_a_plus_b;

    // Next state logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output logic and state transition
    always @(*) begin
        // Defaults
        next_state = state;
        isqrt_x_vld = 0;
        res_vld = 0;
        res = 0;

        case (state)
            IDLE: begin
                if (arg_vld) begin
                    isqrt_x = c;  // Load 'c' to isqrt
                    isqrt_x_vld = 1;
                    next_state = CALC_ISQRT_C;
                end
            end
            CALC_ISQRT_C: begin
                if (isqrt_y_vld) begin
                    result_b_plus_c = b + {16'b0, isqrt_y};  // Concatenate to get 32 bits
                    isqrt_x = result_b_plus_c;
                    isqrt_x_vld = 1;
                    next_state = CALC_ISQRT_B_PLUS_C;
                end
            end
            CALC_ISQRT_B_PLUS_C: begin
                if (isqrt_y_vld) begin
                    result_a_plus_b = a + {16'b0, isqrt_y};  // Concatenate to get 32 bits
                    isqrt_x = result_a_plus_b;
                    isqrt_x_vld = 1;
                    next_state = CALC_ISQRT_A_PLUS_B;
                end
            end
            CALC_ISQRT_A_PLUS_B: begin
                if (isqrt_y_vld) begin
                    res = {16'b0, isqrt_y};  // Concatenate to get 32 bits
                    res_vld = 1;
                    next_state = DONE;
                end
            end
            DONE: begin
                // Stay in DONE state until reset
                if (rst) next_state = IDLE;
                else   next_state = DONE;
            end
        endcase
    end

endmodule