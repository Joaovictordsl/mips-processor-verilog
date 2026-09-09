`timescale 1ns/1ps

// Replays the original six-instruction classroom program without changing RTL.
module tb_program;
    reg clk = 0;
    reg reset = 0;
    wire [31:0] pc, instruction, alu_result;
    integer checks = 0;

    processador dut(clk, reset, pc, instruction, alu_result);

    task check32(input [31:0] actual, input [31:0] expected, input string label);
        begin
            checks = checks + 1;
            if (actual !== expected)
                $fatal(1, "%s: expected %h, got %h", label, expected, actual);
        end
    endtask

    task step(input [31:0] current_pc, input [31:0] next_pc);
        begin
            check32(pc, current_pc, "PC before clock");
            #5; clk = 1; #5; clk = 0; #1;
            check32(pc, next_pc, "PC after clock");
        end
    endtask

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("build/program.vcd");
            $dumpvars(0, tb_program);
        end

        #1; reset = 1; #2; reset = 0; #2;
        check32(dut.REGISTRADORES.registers[8], 5, "initial r8");
        check32(dut.REGISTRADORES.registers[9], 5, "initial r9");
        step(0, 8);  // BEQ taken: skip ADDI.
        check32(dut.REGISTRADORES.registers[8], 5, "skipped ADDI");
        step(8, 12); // SW r8, 0(r12), where r12 = 4.
        check32(dut.MEMORIA_DADOS.memory[1], 5, "first store");
        step(12, 16);
        check32(dut.REGISTRADORES.registers[16], 5, "first load");
        step(16, 20);
        check32(dut.REGISTRADORES.registers[8], 4, "first subtraction");
        step(20, 0);
        step(0, 4);  // BEQ not taken: r8 = 4, r9 = 5.
        step(4, 8);
        check32(dut.REGISTRADORES.registers[8], 6, "executed ADDI");
        step(8, 12);
        check32(dut.MEMORIA_DADOS.memory[1], 6, "second store");
        step(12, 16);
        check32(dut.REGISTRADORES.registers[16], 6, "second load");
        step(16, 20);
        check32(dut.REGISTRADORES.registers[8], 5, "second subtraction");
        step(20, 0);

        $display("PASS tb_program: %0d checks", checks);
        $finish;
    end

    initial begin #1000; $fatal(1, "tb_program timed out"); end
endmodule
