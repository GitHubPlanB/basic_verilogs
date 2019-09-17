module cfg_mem_sync#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input                             soc_clk,
    input                             soc_rstn,

    input                             sys_clk,
    output                            sys_rstn,

    input        [ADDR_WIDTH - 1 : 0] soc_addr         ,
    input        [DATA_WIDTH - 1 : 0] soc_wdata        ,
    output       [DATA_WIDTH - 1 : 0] soc_rdata        ,
    output                            soc_rdata_vld    ,
    input                             soc_wr           ,
    input                             soc_rd           ,

    output       [ADDR_WIDTH - 1 : 0] sys_addr         ,
    output       [DATA_WIDTH - 1 : 0] sys_wdata        ,
    input        [DATA_WIDTH - 1 : 0] sys_rdata        ,
    input                             sys_rdata_vld    ,
    output                            sys_wr           ,
    output                            sys_rd            
);
reg [ADDR_WIDTH - 1 : 0] lock_addr         ;
reg [DATA_WIDTH - 1 : 0] lock_wdata        ;


assign sys_addr = lock_addr;
assign sys_wdata= lock_wdata;

synchronizer synchronizer_u0 ( .clk(sys_clk ), .din(soc_rstn), .dout(sys_rstn) );   

always @ (posedge soc_clk)
begin
    if(!soc_rstn)begin
        lock_wdata          <= 0;
        lock_addr           <= 1'b0;  
    end
    else if (soc_wr || soc_rd) begin
        lock_wdata          <= soc_wdata;
        lock_addr           <= soc_addr ;
    end
end
pulse_sync pulse_sync_u0( .src_clk(soc_clk), .dst_clk(sys_clk), .dst_rstn(sys_rstn), .din(soc_wr), .dout(sys_wr) );
pulse_sync pulse_sync_u1( .src_clk(soc_clk), .dst_clk(sys_clk), .dst_rstn(sys_rstn), .din(soc_rd), .dout(sys_rd) );
bus_synchronizer bus_synchronizer_u0( .src_clk(sys_clk), .dst_clk(soc_clk), .dst_rstn(soc_rstn), .din(sys_rdata), .din_vld(sys_rdata_vld), .dout(soc_rdata), .dout_vld(soc_rdata_vld) );

endmodule

