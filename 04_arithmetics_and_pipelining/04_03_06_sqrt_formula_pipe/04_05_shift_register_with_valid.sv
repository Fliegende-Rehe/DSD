//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_shift_register_with_reset
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,
    input  in_data,
    output out_data
);
    logic [depth - 1:0] data;

    always_ff @ (posedge clk)
        if (rst)
            data <= '0;
        else
            data <= { data [depth - 2:0], in_data };

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        data [0] <= in_data;

        for (int i = 1; i < depth; i ++)
            data [i] <= data [i - 1];
    end

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------
// Task 5
//----------------------------------------------------------------------------

module shift_register_with_valid #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input                clk,
    input                rst,
    input                in_vld,
    input  [WIDTH - 1:0] in_data,
    output               out_vld,
    output [WIDTH - 1:0] out_data
);

    logic [WIDTH - 1:0] data [DEPTH-1:0];
    logic [DEPTH-1:0]   vld;

    always_ff @ (posedge clk) begin
        if (rst) begin
            data <= '{default: '0};
            vld <= '{default: 1'b0};
        end else begin
            if (in_vld) begin
                data <= {data[DEPTH-2:0], in_data};
                vld <= {vld[DEPTH-2:0], 1'b1};
            end
        end
    end

    assign out_data = data[DEPTH - 1];
    assign out_vld = vld[DEPTH - 1];

endmodule
