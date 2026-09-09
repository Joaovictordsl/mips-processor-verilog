`timescale 1ns/1ps

module tb_alu;
    reg [31:0] a, b;
    reg [3:0] op;
    wire [31:0] result;
    wire overflow, zero;
    integer checks = 0;

    ula dut(a, b, op, result, overflow, zero);

    task vector(input [3:0] operation, input [31:0] left, right, expected,
                input check_overflow, expected_overflow, input string label);
        begin
            op = operation; a = left; b = right; #2;
            checks = checks + 1;
            if (result !== expected)
                $fatal(1, "%s result: expected %h, got %h", label, expected, result);
            checks = checks + 1;
            if (zero !== (expected == 0))
                $fatal(1, "%s zero flag", label);
            if (check_overflow) begin
                checks = checks + 1;
                if (overflow !== expected_overflow)
                    $fatal(1, "%s overflow flag", label);
            end
        end
    endtask

    initial begin
        vector(2, 7, 3, 10, 1, 0, "ADD ordinary");
        vector(2, 32'hffffffff, 1, 0, 1, 0, "ADD carry without signed overflow");
        vector(2, 32'h7fffffff, 1, 32'h80000000, 1, 1, "ADD positive overflow");
        vector(2, 32'h80000000, 32'hffffffff, 32'h7fffffff, 1, 1, "ADD negative overflow");
        vector(6, 7, 10, 32'hfffffffd, 1, 0, "SUB negative result");
        vector(6, 5, 5, 0, 1, 0, "SUB equality");
        vector(6, 32'h80000000, 1, 32'h7fffffff, 1, 1, "SUB negative overflow");
        vector(6, 32'h7fffffff, 32'hffffffff, 32'h80000000, 1, 1, "SUB positive overflow");
        vector(7, 32'h80000000, 32'h7fffffff, 1, 0, 0, "SLT min less than max");
        vector(7, 32'h7fffffff, 32'h80000000, 0, 0, 0, "SLT max not less than min");
        vector(7, 32'hffffffff, 0, 1, 0, 0, "SLT signed negative");
        vector(0, 32'hf0f0f0f0, 32'h0ff00ff0, 32'h00f000f0, 0, 0, "AND");
        vector(1, 32'hf0f0f0f0, 32'h0ff00ff0, 32'hfff0fff0, 0, 0, "OR");
        vector(12, 32'hf0f0f0f0, 32'h0ff00ff0, 32'h000f000f, 0, 0, "NOR");
        $display("PASS tb_alu: %0d checks", checks);
        $finish;
    end
endmodule
