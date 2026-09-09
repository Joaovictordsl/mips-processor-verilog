module memDados(
    input wire clk,
    input wire MemRead,
    input wire MemWrite,

    input wire [31:0] address,
    input wire [31:0] write_data,

    output wire [31:0] read_data
);

    reg [31:0] memory [0:255];

    initial begin
        memory[0] = 32'd100;
        memory[1] = 32'd200;
        memory[2] = 32'd300;
        memory[3] = 32'd400;
    end

    assign read_data = (MemRead) ? memory[address[31:2]] : 32'b0;

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[31:2]] <= write_data;
        end
    end

endmodule