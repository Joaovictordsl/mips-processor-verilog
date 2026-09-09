module memInst (
    input wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];

    initial begin
        // Endereço 0: beq $8, $9, 1   -> opcode=4, rs=$8, rt=$9, imm=1
        // (se $8 == $9, pula para PC+4+1*4 = 8)
        memory[0] = 32'b000100_01000_01001_0000000000000001;

        // Endereço 4: addi $8, $8, 2  -> opcode=8, rs=$8, rt=$8, imm=2
        memory[1] = 32'b001000_01000_01000_0000000000000010;

        // Endereço 8: sw $8, 0($12)   -> opcode=43, rs=$12, rt=$8, imm=0
        memory[2] = 32'b101011_01100_01000_0000000000000000;

        // Endereço 12: lw $16, 0($12) -> opcode=35, rs=$12, rt=$16, imm=0
        memory[3] = 32'b100011_01100_10000_0000000000000000;

        // Endereço 16: sub $8, $16, $10 -> Tipo R, funct=34
        // opcode=0, rs=$16, rt=$10, rd=$8, shamt=0, funct=100010
        memory[4] = 32'b000000_10000_01010_01000_00000_100010;

        // Endereço 20: j 0  -> opcode=2, endereço=0
        memory[5] = 32'b000010_00000000000000000000000000;
    end

    assign instruction = memory[address[31:2]];

endmodule
