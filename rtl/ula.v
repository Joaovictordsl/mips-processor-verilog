module ula(
    A,
    B,
    ALUop,
    result,
    overflow,
    zero
);

    input [31:0] A;
    input [31:0] B;
    input [3:0] ALUop;

    output [31:0] result;
    output overflow;
    output zero;

    // SUBTRAÇÃO / SOMA
 
    wire B_inverter = ALUop[2];

    wire [31:0] B_inv =
        B ^ {32{B_inverter}};

    wire [31:0] soma_result;

    wire soma_carryout;
    wire soma_overflow;

    somador soma_sub (
        A,
        B_inv,
        B_inverter,
        soma_result,
        soma_carryout,
        soma_overflow
    );

    // OPERAÇÕES LÓGICAS

    wire [31:0] and_resultado = A & B;

    wire [31:0] or_resultado  = A | B;

    wire [31:0] nor_resultado = ~(A | B);

    // SLT

    wire slt_bit =
        soma_result[31] ^ soma_overflow;

    wire [31:0] slt_resultado =
        {{31{1'b0}}, slt_bit};

    // MUX DA ULA

    reg [31:0] result_reg;

    always @(*) begin

        case (ALUop)

            4'b0000:
                result_reg = and_resultado;

            4'b0001:
                result_reg = or_resultado;

            4'b0010:
                result_reg = soma_result;

            4'b0110:
                result_reg = soma_result;

            4'b0111:
                result_reg = slt_resultado;

            4'b1100:
                result_reg = nor_resultado;

            default:
                result_reg = 32'b0;

        endcase

    end

    // SAÍDAS

    assign result = result_reg;

    assign overflow = soma_overflow;

    assign zero = (result_reg == 32'b0);

endmodule