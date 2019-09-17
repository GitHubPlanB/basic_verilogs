module pulse_sync(
    input    src_clk  ,
    input    dst_clk  ,
    input    dst_rstn ,
    input    din      ,
    output reg  dout
);
reg   lock_src ;
wire  lock_clr_src;

wire  lock_dst ;
reg   lock_clr_dst;

always @ (posedge src_clk )
begin
    if (din)begin
        lock_src <= 1'b1;
    end
    else if (lock_clr_src)
        lock_src <= 1'b0;
end

synchronizer synchronizer_u0 ( .clk(dst_clk ), .din(lock_src), .dout(lock_dst) );
synchronizer synchronizer_u1 ( .clk(src_clk ), .din(lock_clr_dst), .dout(lock_clr_src) );


always @ (posedge dst_clk )
begin
    if (!dst_rstn )begin
        dout  <= 1'b0;
        lock_clr_dst <= 1'b0;
    end
    else if (lock_dst && !lock_clr_dst)begin
        dout  <= 1'b1;
        lock_clr_dst <= 1'b1;
    end
    else if (dout && lock_clr_dst)begin
        dout  <= 1'b0;
    end
    else if (!lock_dst)
        lock_clr_dst <= 1'b0;
end

endmodule
