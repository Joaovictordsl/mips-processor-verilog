`timescale 1ns/1ps

// An independent program checks the supported ISA through architectural state.
module tb_isa;
    reg clk = 0;
    reg reset = 0;
    wire [31:0] pc, instruction, alu_result;
    integer i;
    integer checks = 0;

    processador dut(clk, reset, pc, instruction, alu_result);

    function [31:0] r_type(input [4:0] rs, rt, rd, input [5:0] funct);
        r_type = {6'b0, rs, rt, rd, 5'b0, funct};
    endfunction

    function [31:0] i_type(input [5:0] op, input [4:0] rs, rt, input [15:0] imm);
        i_type = {op, rs, rt, imm};
    endfunction

    function [31:0] j_type(input [25:0] target_word);
        j_type = {6'd2, target_word};
    endfunction

    task check32(input [31:0] actual, input [31:0] expected, input string label);
        begin
            checks = checks + 1;
            if (actual !== expected)
                $fatal(1, "%s: expected %h, got %h", label, expected, actual);
        end
    endtask

    task step(input [31:0] current_pc, input [31:0] next_pc);
        begin
            check32(pc, current_pc, "instruction address");
            #5; clk = 1; #5; clk = 0; #1;
            check32(pc, next_pc, "next instruction address");
        end
    endtask

    initial begin
        // Wait until RTL initial blocks have completed before loading fixtures.
        #1;
        for (i = 0; i < 256; i = i + 1) begin
            dut.MEMORIA_INSTRUCOES.memory[i] = 0;
            dut.MEMORIA_DADOS.memory[i] = 0;
        end
        for (i = 0; i < 32; i = i + 1)
            dut.REGISTRADORES.registers[i] = 0;

        dut.MEMORIA_INSTRUCOES.memory[0]  = i_type(8, 0, 1, 7);
        dut.MEMORIA_INSTRUCOES.memory[1]  = i_type(8, 0, 2, -3);
        dut.MEMORIA_INSTRUCOES.memory[2]  = r_type(1, 2, 3, 32);  // ADD
        dut.MEMORIA_INSTRUCOES.memory[3]  = r_type(1, 2, 4, 34);  // SUB
        dut.MEMORIA_INSTRUCOES.memory[4]  = r_type(1, 4, 5, 36);  // AND
        dut.MEMORIA_INSTRUCOES.memory[5]  = r_type(1, 4, 6, 37);  // OR
        dut.MEMORIA_INSTRUCOES.memory[6]  = r_type(1, 4, 7, 39);  // NOR
        dut.MEMORIA_INSTRUCOES.memory[7]  = r_type(2, 1, 8, 42);  // SLT true
        dut.MEMORIA_INSTRUCOES.memory[8]  = r_type(1, 2, 9, 42);  // SLT false
        dut.MEMORIA_INSTRUCOES.memory[9]  = i_type(8, 0, 0, 99);  // r0 protection
        dut.MEMORIA_INSTRUCOES.memory[10] = i_type(43, 0, 3, 0); // SW
        dut.MEMORIA_INSTRUCOES.memory[11] = i_type(35, 0, 10, 0);// LW
        dut.MEMORIA_INSTRUCOES.memory[12] = i_type(4, 3, 10, 1); // BEQ taken
        dut.MEMORIA_INSTRUCOES.memory[13] = i_type(8, 0, 11, 111);
        dut.MEMORIA_INSTRUCOES.memory[14] = i_type(4, 3, 1, 1);  // BEQ not taken
        dut.MEMORIA_INSTRUCOES.memory[15] = i_type(8, 0, 12, 12);
        dut.MEMORIA_INSTRUCOES.memory[16] = i_type(8, 0, 13, 1);
        dut.MEMORIA_INSTRUCOES.memory[17] = i_type(8, 13, 13, -1);
        dut.MEMORIA_INSTRUCOES.memory[18] = i_type(4, 13, 0, -2);// Backward branch
        dut.MEMORIA_INSTRUCOES.memory[19] = j_type(21);
        dut.MEMORIA_INSTRUCOES.memory[20] = i_type(8, 0, 14, 99);// Skipped by J
        dut.MEMORIA_INSTRUCOES.memory[21] = i_type(8, 0, 15, 15);
        dut.MEMORIA_INSTRUCOES.memory[22] = j_type(22);          // Stop loop

        reset = 1; #2; reset = 0; #2;
        for (i = 0; i < 12; i = i + 1) step(i * 4, (i + 1) * 4);
        step(48, 56);
        step(56, 60);
        step(60, 64);
        step(64, 68);
        step(68, 72);
        step(72, 68);
        step(68, 72);
        step(72, 76);
        step(76, 84);
        step(84, 88);
        step(88, 88);

        check32(dut.REGISTRADORES.registers[0], 0, "r0 is immutable");
        check32(dut.REGISTRADORES.registers[1], 7, "ADDI positive");
        check32(dut.REGISTRADORES.registers[2], 32'hfffffffd, "ADDI negative");
        check32(dut.REGISTRADORES.registers[3], 4, "ADD");
        check32(dut.REGISTRADORES.registers[4], 10, "SUB");
        check32(dut.REGISTRADORES.registers[5], 2, "AND");
        check32(dut.REGISTRADORES.registers[6], 15, "OR");
        check32(dut.REGISTRADORES.registers[7], 32'hfffffff0, "NOR");
        check32(dut.REGISTRADORES.registers[8], 1, "SLT true");
        check32(dut.REGISTRADORES.registers[9], 0, "SLT false");
        check32(dut.REGISTRADORES.registers[10], 4, "LW after SW");
        check32(dut.REGISTRADORES.registers[11], 0, "taken branch skips write");
        check32(dut.REGISTRADORES.registers[12], 12, "not-taken branch executes write");
        check32(dut.REGISTRADORES.registers[13], 32'hffffffff, "backward branch");
        check32(dut.REGISTRADORES.registers[14], 0, "jump skips write");
        check32(dut.REGISTRADORES.registers[15], 15, "jump target executes");
        check32(dut.MEMORIA_DADOS.memory[0], 4, "SW architectural memory");

        $display("PASS tb_isa: %0d checks", checks);
        $finish;
    end

    initial begin #2000; $fatal(1, "tb_isa timed out"); end
endmodule
