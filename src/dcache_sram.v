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
        if(LRU == 1'b1) begin
            data[addr_i][1] <= data_i;
            tag[addr_i][1] <= {1'b1,1'b1,tag_i[22:0]};           
        end
        else if(LRU == 1'b0) begin
            data[addr_i][0] <= data_i;
            tag[addr_i][0] <= {1'b1,1'b1,tag_i[22:0]};
        end     
    end
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?
assign eq1 = tag[addr_i][0] == tag_i? 1'b1: 1'b0;
assign eq2 = tag[addr_i][1] == tag_i? 1'b1: 1'b0;
assign valid1 = eq1 & tag[addr_i][0][24]? 1'b1: 1'b0;
assign valid2 = eq2 & tag[addr_i][1][24]? 1'b1: 1'b0;
assign hit_o = (valid1 | valid2) & enable_i? 1'b1: 1'b0;

assign data_o = ~enable_i? 256'b0:
                write_i? data_i:
                valid1? data[addr_i][0]:
                valid2? data[addr_i][1]:
                ~LRU?  data[addr_i][0]:
                LRU?  data[addr_i][1]: data[addr_i][0];

assign tag_o = ~enable_i? 25'b0:
               write_i? tag_i:
               valid1? tag[addr_i][0]:
               valid2? tag[addr_i][1]:
               ~LRU?  tag[addr_i][0]:
               LRU?  tag[addr_i][1]: tag[addr_i][0];

always @* begin
    LRU = valid1? 1'b1:
    valid2? 1'b0: 1'b0;
end


/*assign tag_o = (enable_i && ~write_i && valid[addr_i][0] && tag[addr_i][0] == tag_i)? tag[addr_i][0]:
               (enable_i && ~write_i && valid[addr_i][1] && tag[addr_i][1] == tag_i)? tag[addr_i][1]:
               (enable_i && ~write_i && LRU == 1'b1)? tag[addr_i][1];
               (enable_i && ~write_i && LRU == 1'b0)? tag[addr_i][0]: tag[addr_i][0];

assign data_o = (enable_i && ~write_i && valid[addr_i][0] && tag[addr_i][0] == tag_i)? data[addr_i][0]:
                (enable_i && ~write_i && valid[addr_i][1] && tag[addr_i][1] == tag_i)? data[addr_i][1]:
                (enable_i && ~write_i && LRU == 1'b1)? data[addr_i][1];
                (enable_i && ~write_i && LRU == 1'b0)? data[addr_i][0]: data[addr_i][0];

assign hit_o = (enable_i && ~write_i && valid[addr_i][0] && tag[addr_i][0] == tag_i)? 1'b1:
               (enable_i && ~write_i && valid[addr_i][1] && tag[addr_i][1] == tag_i)? 1'b1:
               (enable_i && ~write_i && LRU == 1'b1)? 1'b0;
               (enable_i && ~write_i && LRU == 1'b0)? 1'b0: 1'b0;*/

/*always @(enable_i or write_i) begin
    flag = 1'b0;
    if(enable_i == 1'b1 && write_i == 1'b0) begin
        if(valid[addr_i][0]) begin
            if(tag[addr_i][0] == tag_i) begin // set 1 read hit
                tag_o = tag[addr_i][0];
                data_o = data[addr_i][0];
                hit_o = 1'b1;
                LRU = 1'b1;
                flag = 1'b1;
            end
        end
        if(valid[addr_i][1] && flag == 1'b0) begin
            if(tag[addr_i][1] == tag_i) begin // set 2 read hit
                tag_o = tag[addr_i][1];
                data_o = data[addr_i][1];
                hit_o = 1'b1;
                LRU = 1'b0;
                flag = 1'b1;
            end
        end
        if(flag == 1'b0) begin // read miss(?
            if(LRU == 1'b1) begin
                tag_o = tag[addr_i][1];
                data_o = data[addr_i][1];
            end
            else if(LRU == 1'b0) begin
                tag_o = tag[addr_i][0];
                data_o = data[addr_i][0];
            end
            else begin
                tag_o = tag[addr_i][0];
                data_o = data[addr_i][0];
            end
            hit_o = 1'b0;
        end
    end   
end*/

endmodule
