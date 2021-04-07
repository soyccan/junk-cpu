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
reg      [24:0]    tag [0:15][0:1]; // {valid, dirty, tag(22)}
reg      [255:0]   data[0:15][0:1];

integer            i, j;

reg LRU[0:15];  // the index (0 or 1) to be be replaced
wire hit0;
wire hit1;

// Write Data
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
                LRU[i] <= 1'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (hit0) begin
            data[addr_i][0] <= data_i;
            tag[addr_i][0] <= tag_i;
        end
        else if (hit1) begin
            data[addr_i][1] <= data_i;
            tag[addr_i][1] <= tag_i;
        end
        else begin
            data[addr_i][LRU[addr_i]] <= data_i;
            tag[addr_i][LRU[addr_i]] <= tag_i;
        end
    end
end

// Read Data
// TODO: tag_o=? data_o=? hit_o=?
assign hit0 = tag[addr_i][0][22:0] == tag_i[22:0] && tag[addr_i][0][24];
assign hit1 = tag[addr_i][1][22:0] == tag_i[22:0] && tag[addr_i][1][24];
assign hit_o  = (hit0 || hit1) && enable_i;

assign data_o = hit0 ? data[addr_i][0] :
                hit1 ? data[addr_i][1] :
                data[addr_i][LRU[addr_i]];

assign tag_o = hit0 ? tag[addr_i][0] :
               hit1 ? tag[addr_i][1] :
               tag[addr_i][LRU[addr_i]];

always @(posedge clk_i) begin
    if (hit0)
        LRU[addr_i] <= 1'b1;
    else if (hit1)
        LRU[addr_i] <= 1'b0;
    else if (write_i)
        LRU[addr_i] <= ~LRU[addr_i];
    else
        LRU[addr_i] <= LRU[addr_i];
end

endmodule
