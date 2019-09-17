module cfg_count_stat  #(
    parameter DATA_WIDTH = 1 
)(
    input                     clk,
    input                     rstn,
    input                     rd_count_mode,     // 0:rd clear 1: no rd clear 
    input                     sample_mode,       // 0:up edge sample 1:level sample
    input                     rd,
    input    [DATA_WIDTH-1:0] data_in,
    input                     data_in_vld,
    output  reg [31:0]        data_out 
);

reg [31:0] data_tmp;
reg  data_in_r;

always @ (posedge clk)
begin
    if (!rstn)
        data_in_r <= 0;
    else
        data_in_r <= data_in;
end

always @ (posedge clk)
begin
    if (!rstn)
        data_out <= 0;
    else if(rd)begin
        if (sample_mode)
            if (data_in_vld)
                data_out <= data_tmp + data_in;
            else
                data_out <= data_tmp;
        else
            data_out <= data_tmp ;
    end
end

always @ (posedge clk)
begin
    if (!rstn)
        data_tmp <= 0;
    else if(data_in_vld)begin
        case ({rd,rd_count_mode,sample_mode})
        3'b000: data_tmp <= data_tmp + (data_in && !data_in_r);
        3'b001: data_tmp <= data_tmp + data_in;
        3'b010: data_tmp <= data_tmp + (data_in && !data_in_r);
        3'b011: data_tmp <= data_tmp + data_in;
        3'b100: data_tmp <= 0; 
        3'b101: data_tmp <= 0;
        3'b110: data_tmp <= data_tmp + (data_in && !data_in_r);
        3'b111: data_tmp <= data_tmp + data_in;
        endcase
    end
    else if (rd && !rd_count_mode) begin
        data_tmp <= 0;
    end
end

endmodule
