module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output    [24:0]   tag_o;
output    [255:0]  data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];
reg      [255:0]   data[0:15][0:1];

integer            i, j;

reg     LRU;
wire    eq1;
wire    eq2;
wire    valid1;
wire    valid2;
// Write Data
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
                LRU <= 1'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (valid2 || (!hit_o && LRU == 1'b1)) begin
            data[addr_i][1] <= data_i;
            tag[addr_i][1] <= tag_i;
        end
        else if (valid1 || (!hit_o && LRU == 1'b0)) begin
            data[addr_i][0] <= data_i;
            tag[addr_i][0] <= tag_i;
        end
    end
end

// Read Data
// TODO: tag_o=? data_o=? hit_o=?
assign eq1    = tag[addr_i][0][22:0] == tag_i[22:0];
assign eq2    = tag[addr_i][1][22:0] == tag_i[22:0];
assign valid1 = eq1 && tag[addr_i][0][24];
assign valid2 = eq2 && tag[addr_i][1][24];
assign hit_o  = (valid1 || valid2) && enable_i;

assign data_o = valid1 ? data[addr_i][0] :
                valid2 ? data[addr_i][1] :
                ~LRU   ? data[addr_i][0] :
                LRU    ? data[addr_i][1] : 256'bx;

assign tag_o = valid1 ? tag[addr_i][0] :
               valid2 ? tag[addr_i][1] :
               ~LRU   ? tag[addr_i][0] :
               LRU    ? tag[addr_i][1] : 25'bx;

always @(posedge clk_i) begin
    LRU = valid1 ? 1'b1 :
          valid2 ? 1'b0 : 1'b0;
end

endmodule
