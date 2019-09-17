module cfg_test#(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rstn,

    input        [DATA_WIDTH - 1 : 0] in_0_2     ,
    input        [DATA_WIDTH - 1 : 0] in_0_3     ,
    input        [DATA_WIDTH - 1 : 0] in_0_4     ,
    input        [DATA_WIDTH - 1 : 0] in_1_0     ,
    input        [DATA_WIDTH - 1 : 0] in_1_1     ,
    input        [DATA_WIDTH - 1 : 0] in_1_2     ,
    input        [DATA_WIDTH - 1 : 0] in_1_3     ,
    input        [DATA_WIDTH - 1 : 0] in_1_4     ,
    output       [DATA_WIDTH - 1 : 0] out_2_0     ,
    output       [DATA_WIDTH - 1 : 0] out_2_1     ,
    output       [DATA_WIDTH - 1 : 0] out_2_2     ,
    output       [DATA_WIDTH - 1 : 0] out_2_3      
    
);
reg [18:0] cnt;
reg [31:0] reg_0_2;
reg [31:0] reg_2_0;
assign out_2_1 = 1'b1;
assign out_2_2 = 1'b0;
assign out_2_0 = reg_2_0;
always @ (posedge clk)
begin
    if (!rstn)
        reg_0_2 <= 0;
    else
        reg_0_2 <= in_0_2;
end

always @ (posedge clk)
begin
    if (!rstn)
        reg_2_0 <= 0;
    else
        reg_2_0 <= reg_0_2 + 1;
end


always @ (posedge clk)
begin
    if (!rstn)
        cnt <= 0;
    else 
        cnt <= cnt +1;
end

assign out_2_3 = (cnt <100) ? 1'b0 :1'b1;


endmodule
