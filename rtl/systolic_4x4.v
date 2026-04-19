module systolic_4x4 (
    input  wire        clk, rst_n, en,
    // Row inputs (activations) - one per row
    input  wire [7:0]  a_row0, a_row1, a_row2, a_row3,
    // Col inputs (weights) - one per col
    input  wire [7:0]  w_col0, w_col1, w_col2, w_col3,
    // Output accumulators - all 16 results
    output wire [31:0] out_00, out_01, out_02, out_03,
    output wire [31:0] out_10, out_11, out_12, out_13,
    output wire [31:0] out_20, out_21, out_22, out_23,
    output wire [31:0] out_30, out_31, out_32, out_33
);
    // Horizontal wires (activations flowing right)
    wire [7:0] a_00_01, a_01_02, a_02_03;
    wire [7:0] a_10_11, a_11_12, a_12_13;
    wire [7:0] a_20_21, a_21_22, a_22_23;
    wire [7:0] a_30_31, a_31_32, a_32_33;

    // Vertical wires (weights flowing down)
    wire [7:0] w_00_10, w_10_20, w_20_30;
    wire [7:0] w_01_11, w_11_21, w_21_31;
    wire [7:0] w_02_12, w_12_22, w_22_32;
    wire [7:0] w_03_13, w_13_23, w_23_33;

    // Row 0
    pe pe_00(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_row0),.w_in(w_col0),.a_out(a_00_01),.w_out(w_00_10),.acc(out_00));
    pe pe_01(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_00_01),.w_in(w_col1),.a_out(a_01_02),.w_out(w_01_11),.acc(out_01));
    pe pe_02(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_01_02),.w_in(w_col2),.a_out(a_02_03),.w_out(w_02_12),.acc(out_02));
    pe pe_03(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_02_03),.w_in(w_col3),.a_out(),.w_out(w_03_13),.acc(out_03));

    // Row 1
    pe pe_10(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_row1),.w_in(w_00_10),.a_out(a_10_11),.w_out(w_10_20),.acc(out_10));
    pe pe_11(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_10_11),.w_in(w_01_11),.a_out(a_11_12),.w_out(w_11_21),.acc(out_11));
    pe pe_12(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_11_12),.w_in(w_02_12),.a_out(a_12_13),.w_out(w_12_22),.acc(out_12));
    pe pe_13(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_12_13),.w_in(w_03_13),.a_out(),.w_out(w_13_23),.acc(out_13));

    // Row 2
    pe pe_20(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_row2),.w_in(w_10_20),.a_out(a_20_21),.w_out(w_20_30),.acc(out_20));
    pe pe_21(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_20_21),.w_in(w_11_21),.a_out(a_21_22),.w_out(w_21_31),.acc(out_21));
    pe pe_22(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_21_22),.w_in(w_12_22),.a_out(a_22_23),.w_out(w_22_32),.acc(out_22));
    pe pe_23(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_22_23),.w_in(w_13_23),.a_out(),.w_out(w_23_33),.acc(out_23));

    // Row 3
    pe pe_30(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_row3),.w_in(w_20_30),.a_out(a_30_31),.w_out(),.acc(out_30));
    pe pe_31(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_30_31),.w_in(w_21_31),.a_out(a_31_32),.w_out(),.acc(out_31));
    pe pe_32(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_31_32),.w_in(w_22_32),.a_out(a_32_33),.w_out(),.acc(out_32));
    pe pe_33(.clk(clk),.rst_n(rst_n),.en(en),.a_in(a_32_33),.w_in(w_23_33),.a_out(),.w_out(),.acc(out_33));

endmodule
