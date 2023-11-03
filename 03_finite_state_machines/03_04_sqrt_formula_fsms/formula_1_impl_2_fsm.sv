//----------------------------------------------------------------------------
// Task 4
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    //------------------------------------------------------------------------
    // States
    enum logic [2:0]
    {
        st_idle = 3'd0,
        st_compute_a = 3'd1,
        st_compute_b = 3'd2,
        st_compute_c = 3'd3,
        st_accumulate_results = 3'd4
    } state, next_state;

    //------------------------------------------------------------------------
    // Internal signals
    logic [15:0] sqrt_a, sqrt_b, sqrt_c;
    logic sqrt_a_vld, sqrt_b_vld, sqrt_c_vld;

    //------------------------------------------------------------------------
    // Next state logic
    always_comb begin
        // Default assignments
        next_state = state;
        isqrt_1_x_vld = 0;
        isqrt_2_x_vld = 0;
        isqrt_1_x = 0;
        isqrt_2_x = 0;
        res_vld = 0;

        case (state)
            st_idle: begin
                if (arg_vld) begin
                    // Initiate computation of sqrt(a) and sqrt(b)
                    isqrt_1_x = a;
                    isqrt_2_x = b;
                    isqrt_1_x_vld = 1;
                    isqrt_2_x_vld = 1;
                    next_state = st_compute_c;
                end
            end

            st_compute_c: begin
                if (isqrt_1_y_vld && isqrt_2_y_vld) begin
                    // Store the results of sqrt(a) and sqrt(b)
                    sqrt_a = isqrt_1_y;
                    sqrt_b = isqrt_2_y;
                    sqrt_a_vld = 1;
                    sqrt_b_vld = 1;

                    // Initiate computation of sqrt(c)
                    isqrt_1_x = c;
                    isqrt_1_x_vld = 1;
                    next_state = st_accumulate_results;
                end
            end

            st_accumulate_results: begin
                if (isqrt_1_y_vld) begin
                    // Store the result of sqrt(c)
                    sqrt_c = isqrt_1_y;
                    sqrt_c_vld = 1;

                    // Indicate the result will be valid on the next clock edge
                    res_vld = 1;
                    next_state = st_idle;
                end
            end
        endcase
    end

    //------------------------------------------------------------------------
    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= st_idle;
        else
            state <= next_state;
    end

    //------------------------------------------------------------------------
    // Result computation and accumulation
    always_ff @(posedge clk) begin
        if (rst) begin
            res <= 32'd0;
        end else if (state == st_accumulate_results && sqrt_a_vld && sqrt_b_vld && sqrt_c_vld) begin
            // Combine the square root results
            res <= {{16'd0, sqrt_a}} + {{16'd0, sqrt_b}} + {{16'd0, sqrt_c}};
        end
    end

endmodule
