module fifo #(parameter WIDTH = 32, DEPTH = 16)
(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    input vld_in,
    output reg [WIDTH-1:0] data_out,
    output reg vld_out
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] read_ptr, write_ptr;
    wire fifo_full, fifo_empty;

    assign fifo_empty = (read_ptr == write_ptr);
    assign fifo_full = ((write_ptr + 1'b1) == read_ptr);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_ptr <= 0;
            write_ptr <= 0;
            vld_out <= 1'b0;
            data_out <= {WIDTH{1'b0}};
        end else begin
            if (vld_in && !fifo_full) begin
                mem[write_ptr[($clog2(DEPTH)-1):0]] <= data_in;
                write_ptr <= write_ptr + 1'b1;
            end

            if (!fifo_empty && (read_ptr != write_ptr)) begin
                data_out <= mem[read_ptr[($clog2(DEPTH)-1):0]];
                vld_out <= 1'b1;
                read_ptr <= read_ptr + 1'b1;
            end else begin
                vld_out <= 1'b0;
            end
        end
    end

endmodule



//----------------------------------------------------------------------------
// Task 6
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output reg        res_vld,
    output reg [31:0] res
);

    // Parameters for the pipeline stages
    parameter N_STAGES = 16;
    parameter FIFO_DEPTH_1 = N_STAGES;
    parameter FIFO_DEPTH_2 = 2 * N_STAGES + 1;

    // Intermediate valid signals and results
    wire vld1, vld2, vld3;
    wire [31:0] res1, res2, res3;

    // Instantiate the first pipelined isqrt module
    isqrt #(.n_pipe_stages(N_STAGES)) isqrt1
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(vld1),
        .y(res1)
    );

    // FIFOs to align the data for the next stage
    wire [31:0] fifo1_data;
    wire fifo1_vld;

    fifo #(.DEPTH(FIFO_DEPTH_1)) fifo1
    (
        .clk(clk),
        .rst(rst),
        .data_in(b),
        .vld_in(arg_vld),
        .data_out(fifo1_data),
        .vld_out(fifo1_vld)
    );

    // Instantiate the second pipelined isqrt module
    isqrt #(.n_pipe_stages(N_STAGES)) isqrt2
    (
        .clk(clk),
        .rst(rst),
        .x_vld(fifo1_vld),
        .x(fifo1_data + res1),
        .y_vld(vld2),
        .y(res2)
    );

    // FIFOs to align the data for the next stage
    wire [31:0] fifo2_data;
    wire fifo2_vld;

    fifo #(.DEPTH(FIFO_DEPTH_2)) fifo2
    (
        .clk(clk),
        .rst(rst),
        .data_in(a),
        .vld_in(arg_vld),
        .data_out(fifo2_data),
        .vld_out(fifo2_vld)
    );

    // Instantiate the third pipelined isqrt module
    isqrt #(.n_pipe_stages(N_STAGES)) isqrt3
    (
        .clk(clk),
        .rst(rst),
        .x_vld(vld2),
        .x(fifo2_data + res2),
        .y_vld(vld3),
        .y(res3)
    );

    // Register to hold the result
    always @(posedge clk)
    begin
        if (rst)
        begin
            res <= 0;
            res_vld <= 0;
        end
        else
        begin
            res <= res3;
            res_vld <= vld3;
        end
    end

endmodule
