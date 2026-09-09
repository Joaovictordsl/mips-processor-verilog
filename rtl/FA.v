module FA(A, B, carryin, sum, carryout);
    input  A, B, carryin;
    output sum, carryout;

    assign sum = A ^ B ^ carryin;
    assign carryout = (A & B) | (A & carryin) | (B & carryin);
endmodule