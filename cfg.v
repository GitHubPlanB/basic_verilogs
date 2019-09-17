module cfg#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input                             clk          ,
    input                             rstn         ,
    
    input        [ADDR_WIDTH - 1 : 0] addr         ,
    input        [DATA_WIDTH - 1 : 0] wdata        ,
    output  reg  [DATA_WIDTH - 1 : 0] rdata        ,
    output  reg                       rdata_vld    ,
    input                             wr           ,
    input                             rd           ,

    output  reg  [DATA_WIDTH - 1 : 0] addr_0_2     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_0_3     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_0_4     ,
            
    output  reg  [DATA_WIDTH - 1 : 0] addr_1_0     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_1_1     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_1_2     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_1_3     ,
    output  reg  [DATA_WIDTH - 1 : 0] addr_1_4     ,
                                           
    input        [DATA_WIDTH - 1 : 0] addr_2_0     ,
    input        [DATA_WIDTH - 1 : 0] addr_2_1     ,
    input        [DATA_WIDTH - 1 : 0] addr_2_2     ,
    input        [DATA_WIDTH - 1 : 0] addr_2_3      
);
localparam  RD_COUNT_MODE_0   = 6'h0  ;  // offset 0x0
localparam  SAMPLE_MODE_0   = 6'h1  ;  // offset 0x4
localparam  ADDR_0_2   = 6'h2  ;  // offset 0x8
localparam  ADDR_0_3   = 6'h3  ;  // offset 0xC
localparam  ADDR_0_4   = 6'h4  ;  // offset 0x10

localparam  ADDR_1_0   = 6'h10  ;  // offset 0x40
localparam  ADDR_1_1   = 6'h11  ;  // offset 0x44
localparam  ADDR_1_2   = 6'h12  ;  // offset 0x48
localparam  ADDR_1_3   = 6'h13  ;  // offset 0x4C
localparam  ADDR_1_4   = 6'h14  ;  // offset 0x50

localparam  ADDR_2_0   = 6'h20  ;  // offset 0x80
localparam  ADDR_2_1   = 6'h21  ;  // offset 0x84
localparam  ADDR_2_2   = 6'h22  ;  // offset 0x88
localparam  ADDR_2_3   = 6'h23  ;  // offset 0x8C

reg rd_count_mode;
reg sample_mode;

reg rdata_vld_r ;
reg rd_r;
reg [31:0]  addr_r;
reg [DATA_WIDTH - 1 : 0] addr_2_3_cnt;      

always @ (posedge clk)
begin
    rd_r <= rd ;
    addr_r   <= addr ;
end

always @ (posedge clk)
begin
    rdata_vld_r <= rd ;
    rdata_vld   <= rdata_vld_r ;
end
always @ (posedge clk)
begin
    if (!rstn)begin
        rd_count_mode  <= 1'h0 ;
        sample_mode  <= 1'h0 ;
        addr_0_2  <= 32'h0 ;
        addr_0_3  <= 32'h0 ;
        addr_0_4  <= 32'h0 ;
        addr_1_0  <= 32'h0 ;
        addr_1_1  <= 32'h0 ;
        addr_1_2  <= 32'h0 ;
        addr_1_3  <= 32'h0 ;
        addr_1_4  <= 32'h0 ;
    end
    else if (wr) begin
        case (addr[5:0])
            RD_COUNT_MODE_0 :
                rd_count_mode <= wdata[0] ;
            SAMPLE_MODE_0 :
                sample_mode <= wdata[0] ;
            ADDR_0_2 :
                addr_0_2 <= wdata ;
            ADDR_0_3 :
                addr_0_3 <= wdata ;
            ADDR_0_4 :
                addr_0_4 <= wdata ;
            ADDR_1_0 :
                addr_1_0 <= wdata ;
            ADDR_1_1 :
                addr_1_1 <= wdata ;
            ADDR_1_2 :
                addr_1_2 <= wdata ;
            ADDR_1_3 :
                addr_1_3 <= wdata ;
            ADDR_1_4 :
                addr_1_4 <= wdata ;
        endcase
    end
end

always @ (posedge clk)
begin
    if (!rstn) begin
        rdata <= 32'b0;
    end
    else if (rd_r) begin
        case (addr_r[5:0])
            RD_COUNT_MODE_0:
                rdata <= {31'b0,rd_count_mode};
            SAMPLE_MODE_0:
                rdata <= {31'b0,sample_mode};
            ADDR_0_2:
                rdata <= addr_0_2;
            ADDR_0_3:
                rdata <= addr_0_3;
            ADDR_0_4:
                rdata <= addr_0_4;
            ADDR_1_0:
                rdata <= addr_1_0;
            ADDR_1_1:
                rdata <= addr_1_1;
            ADDR_1_2:
                rdata <= addr_1_2;
            ADDR_1_3:
                rdata <= addr_1_3;
            ADDR_1_4:
                rdata <= addr_1_4;
            ADDR_2_0:
                rdata <= addr_2_0;
            ADDR_2_1:
                rdata <= addr_2_1;
            ADDR_2_2:
                rdata <= addr_2_2;
            ADDR_2_3:
                rdata <= addr_2_3_cnt;
            default :
                rdata <= 32'hf0f0f0f0;
        endcase
    end
end

wire addr_2_3_rd;
assign addr_2_3_rd = (addr[5:0] == ADDR_2_3 ) ? rd : 1'b0;
cfg_count_stat  addr_2_3_stat(
    .clk(clk),
    .rstn(rstn),
    .rd_count_mode(rd_count_mode),
    .sample_mode(sample_mode),
    .rd(addr_2_3_rd),
    .data_in(addr_2_3[0]),
    .data_in_vld(1'b1),
    .data_out(addr_2_3_cnt) 
);


endmodule
