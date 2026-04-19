`timescale 1ns/1ns
module tb_systolic2;

    reg clk, rst_n, en;
    reg [7:0] a_row0, a_row1, a_row2, a_row3;
    reg [7:0] w_col0, w_col1, w_col2, w_col3;

    wire [31:0] out_00, out_01, out_02, out_03;
    wire [31:0] out_10, out_11, out_12, out_13;
    wire [31:0] out_20, out_21, out_22, out_23;
    wire [31:0] out_30, out_31, out_32, out_33;

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

    // A matrix
    reg [7:0] A [0:3][0:3];
    // B matrix
    reg [7:0] B [0:3][0:3];
    // Expected C
    integer C [0:3][0:3];
    integer i, j, k, pass, fail;

    initial begin
        $dumpfile("sim/systolic2.vcd");
        $dumpvars(0, tb_systolic2);

        clk=0; rst_n=0; en=0;
        a_row0=0; a_row1=0; a_row2=0; a_row3=0;
        w_col0=0; w_col1=0; w_col2=0; w_col3=0;

        // Matrix A
        A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;
        A[1][0]=5;  A[1][1]=6;  A[1][2]=7;  A[1][3]=8;
        A[2][0]=9;  A[2][1]=10; A[2][2]=11; A[2][3]=12;
        A[3][0]=13; A[3][1]=14; A[3][2]=15; A[3][3]=16;

        // Matrix B (non-trivial)
        B[0][0]=2; B[0][1]=0; B[0][2]=1; B[0][3]=0;
        B[1][0]=0; B[1][1]=3; B[1][2]=0; B[1][3]=1;
        B[2][0]=1; B[2][1]=0; B[2][2]=2; B[2][3]=0;
        B[3][0]=0; B[3][1]=1; B[3][2]=0; B[3][3]=3;

        // Golden C
        C[0][0]=5;  C[0][1]=10; C[0][2]=7;  C[0][3]=14;
        C[1][0]=17; C[1][1]=26; C[1][2]=19; C[1][3]=30;
        C[2][0]=29; C[2][1]=42; C[2][2]=31; C[2][3]=46;
        C[3][0]=41; C[3][1]=58; C[3][2]=43; C[3][3]=62;

        repeat(4) @(posedge clk);
        rst_n = 1; en = 1;
        repeat(2) @(posedge clk);

        // Diagonal skew feeding
        @(posedge clk);
        a_row0=A[0][0]; a_row1=0;       a_row2=0;       a_row3=0;
        w_col0=B[0][0]; w_col1=0;       w_col2=0;       w_col3=0;

        @(posedge clk);
        a_row0=A[0][1]; a_row1=A[1][0]; a_row2=0;       a_row3=0;
        w_col0=B[1][0]; w_col1=B[0][1]; w_col2=0;       w_col3=0;

        @(posedge clk);
        a_row0=A[0][2]; a_row1=A[1][1]; a_row2=A[2][0]; a_row3=0;
        w_col0=B[2][0]; w_col1=B[1][1]; w_col2=B[0][2]; w_col3=0;

        @(posedge clk);
        a_row0=A[0][3]; a_row1=A[1][2]; a_row2=A[2][1]; a_row3=A[3][0];
        w_col0=B[3][0]; w_col1=B[2][1]; w_col2=B[1][2]; w_col3=B[0][3];

        @(posedge clk);
        a_row0=0;       a_row1=A[1][3]; a_row2=A[2][2]; a_row3=A[3][1];
        w_col0=0;       w_col1=B[3][1]; w_col2=B[2][2]; w_col3=B[1][3];

        @(posedge clk);
        a_row0=0;       a_row1=0;       a_row2=A[2][3]; a_row3=A[3][2];
        w_col0=0;       w_col1=0;       w_col2=B[3][2]; w_col3=B[2][3];

        @(posedge clk);
        a_row0=0;       a_row1=0;       a_row2=0;       a_row3=A[3][3];
        w_col0=0;       w_col1=0;       w_col2=0;       w_col3=B[3][3];

        @(posedge clk);
        a_row0=0; a_row1=0; a_row2=0; a_row3=0;
        w_col0=0; w_col1=0; w_col2=0; w_col3=0;
        repeat(5) @(posedge clk);

        // Verify
        pass=0; fail=0;
        $display("\n=== Test 2: Non-Trivial Matrix ===");
        $display("RTL Output:");
        $display("  [%0d, %0d, %0d, %0d]", out_00,out_01,out_02,out_03);
        $display("  [%0d, %0d, %0d, %0d]", out_10,out_11,out_12,out_13);
        $display("  [%0d, %0d, %0d, %0d]", out_20,out_21,out_22,out_23);
        $display("  [%0d, %0d, %0d, %0d]", out_30,out_31,out_32,out_33);
        $display("Expected:");
        $display("  [5, 10, 7, 14]");
        $display("  [17, 26, 19, 30]");
        $display("  [29, 42, 31, 46]");
        $display("  [41, 58, 43, 62]");

        if(out_00==5  && out_01==10 && out_02==7  && out_03==14) begin $display("Row 0: PASS"); pass=pass+1; end
        else begin $display("Row 0: FAIL got [%0d,%0d,%0d,%0d]",out_00,out_01,out_02,out_03); fail=fail+1; end

        if(out_10==17 && out_11==26 && out_12==19 && out_13==30) begin $display("Row 1: PASS"); pass=pass+1; end
        else begin $display("Row 1: FAIL got [%0d,%0d,%0d,%0d]",out_10,out_11,out_12,out_13); fail=fail+1; end

        if(out_20==29 && out_21==42 && out_22==31 && out_23==46) begin $display("Row 2: PASS"); pass=pass+1; end
        else begin $display("Row 2: FAIL got [%0d,%0d,%0d,%0d]",out_20,out_21,out_22,out_23); fail=fail+1; end

        if(out_30==41 && out_31==58 && out_32==43 && out_33==62) begin $display("Row 3: PASS"); pass=pass+1; end
        else begin $display("Row 3: FAIL got [%0d,%0d,%0d,%0d]",out_30,out_31,out_32,out_33); fail=fail+1; end

        $display("\n=== %0d/4 PASS | %0d/4 FAIL ===", pass, fail);
        if (fail==0) $display("*** ALL PASS — Non-Trivial Matrix Verified! ***");

        $finish;
    end
endmodule
