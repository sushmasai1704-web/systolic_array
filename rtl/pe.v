module pe (
    input  wire        clk, rst_n,
    input  wire        en,
    input  wire [7:0]  a_in,      // from left
    input  wire [7:0]  w_in,      // weight from top
    output reg  [7:0]  a_out,     // pass right
    output reg  [7:0]  w_out,     // pass down
    output reg  [31:0] acc        // accumulated sum
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 0;
            w_out <= 0;
            acc   <= 0;
        end else if (en) begin
            a_out <= a_in;           // pass activation right
            w_out <= w_in;           // pass weight down
            acc   <= acc + (a_in * w_in);  // MAC
        end
    end
endmodule
