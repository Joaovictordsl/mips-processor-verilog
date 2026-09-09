module somador #(parameter N = 32)(
    input [N-1:0] A, B,
    input cin,
    output [N-1:0] result,
    output carryout,
    output overflow
);
    wire [N:0] carry;
    assign carry[0] = cin;
    assign carryout = carry[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : adder_stage
            FA fa_inst(
                .A(A[i]),
                .B(B[i]),
                .carryin(carry[i]),
                .sum(result[i]),
                .carryout(carry[i+1])
            );
        end
    endgenerate

    assign overflow = (A[N-1] ^ result[N-1]) & ~(A[N-1] ^ B[N-1]);
endmodule