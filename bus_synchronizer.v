module bus_synchronizer#(
    parameter DATA_WIDTH = 32
)(
    input     src_clk   ,
    input     dst_clk   ,
    input     dst_rstn   ,

    input [DATA_WIDTH-1:0] din  ,
    input                  din_vld  ,
    output   reg [DATA_WIDTH-1:0] dout     ,
    output   reg                  dout_vld
);

reg [DATA_WIDTH-1:0] lock_din  ;
wire                 din_vld_tmp;

always @ (posedge src_clk)
begin
    if (din_vld)
        lock_din  <= din ;
end

always @ (posedge dst_clk)
begin
    dout_vld    <= din_vld_tmp ;
end

always @ (posedge dst_clk)
begin
    if (din_vld_tmp)
        dout    <= lock_din;
end
pulse_sync pulse_sync_u0( .src_clk(src_clk), .dst_clk(dst_clk), .dst_rstn(dst_rstn), .din(din_vld), .dout(din_vld_tmp) );

endmodule
