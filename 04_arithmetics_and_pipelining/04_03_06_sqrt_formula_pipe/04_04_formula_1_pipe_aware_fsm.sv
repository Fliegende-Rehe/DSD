//----------------------------------------------------------------------------
// Task 4
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm (
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

    // Define states
    localparam [1:0] IDLE = 2'd0,
                     CALC_A = 2'd1,
                     CALC_B = 2'd2,
                     CALC_C = 2'd3;

    // State and temporary registers
    reg [1:0] current_state, next_state;
    reg [31:0] temp_a, temp_b, temp_c;
    reg [31:0] sum;

    // FSM State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE:
                next_state = arg_vld ? CALC_A : IDLE;
            CALC_A:
                next_state = isqrt_y_vld ? CALC_B : CALC_A;
            CALC_B:
                next_state = isqrt_y_vld ? CALC_C : CALC_B;
            CALC_C:
                next_state = isqrt_y_vld ? IDLE : CALC_C;
            default:
                next_state = IDLE;
        endcase
    end

    // Output logic and data processing
    always @(posedge clk) begin
        if (rst) begin
            res_vld <= 0;
            res <= 0;
            sum <= 0;
        end
        else begin
            case (current_state)
                CALC_A: begin
                    if (arg_vld) begin
                        isqrt_x_vld <= 1;
                        isqrt_x <= a;
                        temp_b <= b;
                        temp_c <= c;
                    end
                end
                CALC_B: begin
                    if (isqrt_y_vld) begin
                        sum <= isqrt_y;
                        isqrt_x_vld <= 1;
                        isqrt_x <= temp_b;
                    end
                end
                CALC_C: begin
                    if (isqrt_y_vld) begin
                        sum <= sum + isqrt_y;
                        isqrt_x_vld <= 1;
                        isqrt_x <= temp_c;
                    end
                end
                IDLE: begin
                    if (isqrt_y_vld) begin
                        sum <= sum + isqrt_y;
                        res <= sum;
                        res_vld <= 1;
                        isqrt_x_vld <= 0;
                    end
                    else if (res_vld) begin
                        res_vld <= 0;
                        sum <= 0;
                    end
                end
            endcase
        end
    end

endmodule

