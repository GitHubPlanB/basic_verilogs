module cfg_test_top(
    input clk ,
    input rstn ,

    input        [32 - 1 : 0] addr         ,
    input        [32 - 1 : 0] wdata        ,
    output       [32 - 1 : 0] rdata        ,
    output                    rdata_vld    ,
    input                     wr           ,
    input                     rd            

);

wire [31:0] in_0_2   ;
wire [31:0] in_0_3   ;
wire [31:0] in_0_4   ;
wire [31:0] in_1_0   ;
wire [31:0] in_1_1   ;
wire [31:0] in_1_2   ;
wire [31:0] in_1_3   ;
wire [31:0] in_1_4   ;
wire [31:0] out_2_0  ;
wire [31:0] out_2_1  ;
wire [31:0] out_2_2  ;
wire [31:0] out_2_3  ;

cfg_test cfg_test_u0(
    .clk        ( clk       ),
    .rstn       ( rstn      ),
                          
    .in_0_2     ( in_0_2    ),
    .in_0_3     ( in_0_3    ),
    .in_0_4     ( in_0_4    ),
    .in_1_0     ( in_1_0    ),
    .in_1_1     ( in_1_1    ),
    .in_1_2     ( in_1_2    ),
    .in_1_3     ( in_1_3    ),
    .in_1_4     ( in_1_4    ),
    .out_2_0    ( out_2_0   ),
    .out_2_1    ( out_2_1   ),
    .out_2_2    ( out_2_2   ),
    .out_2_3    ( out_2_3   )  
    
);


cfg cfg_u0(
    .clk          (clk         ),
    .rstn         (rstn        ),
                            
    .addr         (addr        ),
    .wdata        (wdata       ),
    .rdata        (rdata       ),
    .rdata_vld    (rdata_vld   ),
    .wr           (wr          ),
    .rd           (rd          ),
                            
    .addr_0_2     (in_0_2     ),
    .addr_0_3     (in_0_3     ),
    .addr_0_4     (in_0_4     ),
    .addr_1_0     (in_1_0     ),
    .addr_1_1     (in_1_1     ),
    .addr_1_2     (in_1_2     ),
    .addr_1_3     (in_1_3     ),
    .addr_1_4     (in_1_4     ),
    .addr_2_0     (out_2_0    ),
    .addr_2_1     (out_2_1    ),
    .addr_2_2     (out_2_2    ),
    .addr_2_3     (out_2_3    ) 
);
endmodule
