module Data_Memory
(
    clk_i, 
    rst_i,
    addr_i, 
    enable_i,
    write_i,
    data_i,
    data_o,
    ack_o
);

// Interface
input               clk_i;
input               rst_i;
input   [31:0]      addr_i;
input               enable_i;
input               write_i;
input   [255:0]      data_i;
output  [255:0]      data_o;
output              ack_o;

// data memory
reg     [255:0]     memory  [0:1023];

integer i;

assign  data_o = enable_i ? memory[addr_i >> 2] : 0;
assign  ack_o = 1'b1;

always @ (posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 256'b0;
        end
    end
    else if (write_i) begin
        // Unaligned write should be avoided. addr_i%4 must be 0.
        memory[addr_i >> 2] <= data_i;
    end
end

endmodule
