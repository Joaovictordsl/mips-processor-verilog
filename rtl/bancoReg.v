module bancoReg (
    input wire clk,
    input wire regWrite,

    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] registers [31:0];

    // Inicialização conforme Prática 7:
    // $8 = 5, $9 = 5, $10 = 1, $12 = 4
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
        registers[8]  = 32'd5;
        registers[9]  = 32'd5;
        registers[10] = 32'd1;
        registers[12] = 32'd4;
    end

    // $0 sempre vale 0
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

    always @(posedge clk) begin
        if (regWrite && (write_reg != 0)) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
