module synchronizer#(
    parameter DELAY_NUM =2,
    parameter DATA_WIDTH = 1
)(
    input        clk,
    input [DATA_WIDTH-1:0] din,
    output[DATA_WIDTH-1:0] dout
);
reg  [DATA_WIDTH-1:0] data [0:DELAY_NUM-1];
always @ (posedge clk)
begin
    data[0] <= din ;            
end

genvar i;
generate 
    for (i=1; i < DELAY_NUM; i=i+1)
    begin:LOOP
        always @ (posedge clk)
        begin
            data[i] <= data[i-1] ;            
        end
    end
endgenerate

assign dout = data[DELAY_NUM-1];

endmodule

