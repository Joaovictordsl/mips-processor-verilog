module extensor(

    input  wire [15:0] in,
    output wire [31:0] out

);

    // Extensão de sinal:
    // replica o bit mais significativo

    assign out =
        {{16{in[15]}}, in};

endmodule