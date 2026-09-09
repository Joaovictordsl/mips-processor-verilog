module processador(
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_instruction,
    output wire [31:0] debug_ula_result
);

    // PC
    wire [31:0] pc_atual;
    wire [31:0] pc_mais_4;
    wire [31:0] branch_address;
    wire [31:0] jump_address;
    wire [31:0] prox_pc;

    // Memória de instruções
    wire [31:0] instruction;

    // Campos da instrução
    wire [5:0]  opcode;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [5:0]  funct;
    wire [15:0] immediate;
    wire [25:0] instr_index;

    // Controle
    wire RegDst;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    wire Jump;

    // Banco de registradores
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [4:0]  write_reg;
    wire [31:0] write_data;

    // Extensor
    wire [31:0] sign_extended;

    // ULA
    wire [31:0] ula_entradaB;
    wire [3:0]  ALUControl;
    wire [31:0] ula_result;
    wire overflow;
    wire zero;

    // Memória de dados
    wire [31:0] mem_read_data;

    // =====================
    // PC
    // =====================

    pc PC (
        .clk(clk),
        .reset(reset),
        .next_pc(prox_pc),
        .current_pc(pc_atual)
    );

    assign pc_mais_4 = pc_atual + 4;

    // BEQ: PC+4 + (imediato estendido << 2)
    assign branch_address = pc_mais_4 + (sign_extended << 2);

    // JUMP: {PC+4[31:28], instr_index, 2'b00}
    assign jump_address = {pc_mais_4[31:28], instr_index, 2'b00};

    // MUX próximo PC: Jump > Branch > PC+4
    assign prox_pc = Jump              ? jump_address   :
                     (Branch && zero)  ? branch_address :
                                         pc_mais_4;

    // =====================
    // MEMÓRIA DE INSTRUÇÕES
    // =====================

    memInst MEMORIA_INSTRUCOES (
        .address(pc_atual),
        .instruction(instruction)
    );

    // =====================
    // DECODIFICAÇÃO
    // =====================

    assign opcode      = instruction[31:26];
    assign rs          = instruction[25:21];
    assign rt          = instruction[20:16];
    assign rd          = instruction[15:11];
    assign immediate   = instruction[15:0];
    assign funct       = instruction[5:0];
    assign instr_index = instruction[25:0];

    // =====================
    // UNIDADE DE CONTROLE
    // =====================

    controle CONTROLE (
        .opcode(opcode),
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump)
    );

    // =====================
    // BANCO DE REGISTRADORES
    // =====================

    assign write_reg = (RegDst) ? rd : rt;

    bancoReg REGISTRADORES (
        .clk(clk),
        .regWrite(RegWrite),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // =====================
    // EXTENSOR DE SINAL
    // =====================

    extensor EXTENSOR (
        .in(immediate),
        .out(sign_extended)
    );

    // =====================
    // ALU CONTROL
    // =====================

    aluControl ALU_CONTROL (
        .ALUOp(ALUOp),
        .funct(funct),
        .ALUControl(ALUControl)
    );

    // =====================
    // ULA
    // =====================

    assign ula_entradaB = (ALUSrc) ? sign_extended : read_data2;

    ula ULA (
        .A(read_data1),
        .B(ula_entradaB),
        .ALUop(ALUControl),
        .result(ula_result),
        .overflow(overflow),
        .zero(zero)
    );

    // =====================
    // MEMÓRIA DE DADOS
    // =====================

    memDados MEMORIA_DADOS (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(ula_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // MUX MemtoReg
    assign write_data = (MemtoReg) ? mem_read_data : ula_result;

    // Saídas de debug
    assign debug_pc          = pc_atual;
    assign debug_instruction = instruction;
    assign debug_ula_result  = ula_result;

endmodule
