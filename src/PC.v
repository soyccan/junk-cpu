module PC
(
    input               Clk_i,
    input               Rst_i,
    input               Start_i,
    input               PCWrite_i,
    input      [31:0]   PC_i,
    output reg [31:0]   PC_o
);


always @(posedge Clk_i) begin
    if (Rst_i) begin
        PC_o <= 32'b0;
    end  
    else begin
        if (PCWrite_i) begin
            if (Start_i)
                PC_o <= PC_i;
            else
                PC_o <= 32'b0;
        end
    end
end

endmodule
