module aluControl(
    input  wire [1:0] ALUOp,
    input  wire [5:0] funct,
    output reg  [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)

            // lw/sw/addi: soma
            2'b00:
                ALUControl = 4'b0010;

            // beq: subtração
            2'b01:
                ALUControl = 4'b0110;

            // Tipo R:s
            2'b10: begin
                case (funct)

                    // add
                    6'b100000:
                        ALUControl = 4'b0010;

                    // sub
                    6'b100010:
                        ALUControl = 4'b0110;

                    // and
                    6'b100100:
                        ALUControl = 4'b0000;

                    // or
                    6'b100101:
                        ALUControl = 4'b0001;

                    // slt
                    6'b101010:
                        ALUControl = 4'b0111;

                    // nor
                    6'b100111:
                        ALUControl = 4'b1100;

                    default:
                        ALUControl = 4'b0010;

                endcase
            end

            default:
                ALUControl = 4'b0010;

        endcase
    end

endmodule