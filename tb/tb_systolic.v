`timescale 1ns/1ns
module tb_systolic;

    reg clk, rst_n, en;

    // Activation inputs (rows of A, fed skewed)
    reg [7:0] a_row0, a_row1, a_row2, a_row3;
    // Weight inputs (cols of B, fed skewed)
    reg [7:0] w_col0, w_col1, w_col2, w_col3;

    // Outputs
    wire [31:0] out_00, out_01, out_02, out_03;
    wire [31:0] out_10, out_11, out_12, out_13;
    wire [31:0] out_20, out_21, out_22, out_23;
    wire [31:0] out_30, out_31, out_32, out_33;

    // DUT
    systolic_4x4 dut (
        .clk(clk), .rst_n(rst_n), .en(en),
        .a_row0(a_row0), .a_row1(a_row1),
        .a_row2(a_row2), .a_row3(a_row3),
        .w_col0(w_col0), .w_col1(w_col1),
        .w_col2(w_col2), .w_col3(w_col3),
        .out_00(out_00), .out_01(out_01),
        .out_02(out_02), .out_03(out_03),
        .out_10(out_10), .out_11(out_11),
        .out_12(out_12), .out_13(out_13),
        .out_20(out_20), .out_21(out_21),
        .out_22(out_22), .out_23(out_23),
        .out_30(out_30), .out_31(out_31),
        .out_32(out_32), .out_33(out_33)
    );

    always #5 clk = ~clk;

    // A matrix rows
    reg [7:0] A [0:3][0:3];
    // B matrix cols
    reg [7:0] B [0:3][0:3];
    // Expected C
    integer C [0:3][0:3];

    integer i, j, k, pass, fail;

    initial begin
        $dumpfile("sim/systolic.vcd");
        $dumpvars(0, tb_systolic);

        clk=0; rst_n=0; en=0;
        a_row0=0; a_row1=0; a_row2=0; a_row3=0;
        w_col0=0; w_col1=0; w_col2=0; w_col3=0;

        // Matrix A
        A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;
        A[1][0]=5;  A[1][1]=6;  A[1][2]=7;  A[1][3]=8;
        A[2][0]=9;  A[2][1]=10; A[2][2]=11; A[2][3]=12;
        A[3][0]=13; A[3][1]=14; A[3][2]=15; A[3][3]=16;

        // Matrix B = Identity
        for (i=0;i<4;i=i+1)
            for (j=0;j<4;j=j+1)
                B[i][j] = (i==j) ? 1 : 0;

        // Compute expected C = A x B
        for (i=0;i<4;i=i+1)
            for (j=0;j<4;j=j+1) begin
                C[i][j] = 0;
                for (k=0;k<4;k=k+1)
                    C[i][j] = C[i][j] + A[i][k]*B[k][j];
            end

        repeat(4) @(posedge clk);
        rst_n = 1;
        en    = 1;
        repeat(2) @(posedge clk);

        // Feed data skewed (systolic diagonal feeding)
        // Cycle 1
        @(posedge clk);
        a_row0=A[0][0]; a_row1=0;        a_row2=0;        a_row3=0;
        w_col0=B[0][0]; w_col1=0;        w_col2=0;        w_col3=0;

        // Cycle 2
        @(posedge clk);
        a_row0=A[0][1]; a_row1=A[1][0];  a_row2=0;        a_row3=0;
        w_col0=B[1][0]; w_col1=B[0][1];  w_col2=0;        w_col3=0;

        // Cycle 3
        @(posedge clk);
        a_row0=A[0][2]; a_row1=A[1][1];  a_row2=A[2][0];  a_row3=0;
        w_col0=B[2][0]; w_col1=B[1][1];  w_col2=B[0][2];  w_col3=0;

        // Cycle 4
        @(posedge clk);
        a_row0=A[0][3]; a_row1=A[1][2];  a_row2=A[2][1];  a_row3=A[3][0];
        w_col0=B[3][0]; w_col1=B[2][1];  w_col2=B[1][2];  w_col3=B[0][3];

        // Cycle 5
        @(posedge clk);
        a_row0=0;       a_row1=A[1][3];  a_row2=A[2][2];  a_row3=A[3][1];
        w_col0=0;       w_col1=B[3][1];  w_col2=B[2][2];  w_col3=B[1][3];

        // Cycle 6
        @(posedge clk);
        a_row0=0;       a_row1=0;        a_row2=A[2][3];  a_row3=A[3][2];
        w_col0=0;       w_col1=0;        w_col2=B[3][2];  w_col3=B[2][3];

        // Cycle 7
        @(posedge clk);
        a_row0=0;       a_row1=0;        a_row2=0;        a_row3=A[3][3];
        w_col0=0;       w_col1=0;        w_col2=0;        w_col3=B[3][3];

        // Drain pipeline
        @(posedge clk); a_row0=0; a_row1=0; a_row2=0; a_row3=0;
                        w_col0=0; w_col1=0; w_col2=0; w_col3=0;
        repeat(5) @(posedge clk);

        // Check results
        pass=0; fail=0;
        $display("\n=== Systolic Array 4x4 Results ===");
        $display("RTL Output Matrix C:");

        $display("  [%0d, %0d, %0d, %0d]", out_00, out_01, out_02, out_03);
        $display("  [%0d, %0d, %0d, %0d]", out_10, out_11, out_12, out_13);
        $display("  [%0d, %0d, %0d, %0d]", out_20, out_21, out_22, out_23);
        $display("  [%0d, %0d, %0d, %0d]", out_30, out_31, out_32, out_33);

        $display("\nExpected Matrix C:");
        $display("  [%0d, %0d, %0d, %0d]", C[0][0],C[0][1],C[0][2],C[0][3]);
        $display("  [%0d, %0d, %0d, %0d]", C[1][0],C[1][1],C[1][2],C[1][3]);
        $display("  [%0d, %0d, %0d, %0d]", C[2][0],C[2][1],C[2][2],C[2][3]);
        $display("  [%0d, %0d, %0d, %0d]", C[3][0],C[3][1],C[3][2],C[3][3]);

        // Verify row 0
        if(out_00==C[0][0] && out_01==C[0][1] && out_02==C[0][2] && out_03==C[0][3]) begin
            $display("\nRow 0: PASS"); pass=pass+1; end
        else begin $display("\nRow 0: FAIL"); fail=fail+1; end

        // Verify row 1
        if(out_10==C[1][0] && out_11==C[1][1] && out_12==C[1][2] && out_13==C[1][3]) begin
            $display("Row 1: PASS"); pass=pass+1; end
        else begin $display("Row 1: FAIL"); fail=fail+1; end

        // Verify row 2
        if(out_20==C[2][0] && out_21==C[2][1] && out_22==C[2][2] && out_23==C[2][3]) begin
            $display("Row 2: PASS"); pass=pass+1; end
        else begin $display("Row 2: FAIL"); fail=fail+1; end

        // Verify row 3
        if(out_30==C[3][0] && out_31==C[3][1] && out_32==C[3][2] && out_33==C[3][3]) begin
            $display("Row 3: PASS"); pass=pass+1; end
        else begin $display("Row 3: FAIL"); fail=fail+1; end

        $display("\n=== %0d/4 PASS | %0d/4 FAIL ===", pass, fail);
        if (fail==0) $display("*** ALL PASS — Systolic Array Verified! ***");

        $finish;
    end
endmodule
