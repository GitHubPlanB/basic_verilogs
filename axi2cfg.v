`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/29 10:04:17
// Design Name: 
// Module Name: axi2cfg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi2cfg(
    input wire aclk                   ,           
    input wire aresetn                ,           

    input  wire [31 : 0]    m_axi_awaddr  ,           
    input  wire [2 : 0]     m_axi_awprot  ,           
    input  wire             m_axi_awvalid ,           
    output wire             m_axi_awready ,           

    input  wire [31 : 0]    m_axi_wdata   ,           
    input  wire [3 : 0]     m_axi_wstrb   ,           
    input  wire             m_axi_wvalid  ,           
    output wire             m_axi_wready  ,           

    output wire [1 : 0]     m_axi_bresp   ,           
    output wire             m_axi_bvalid  ,           
    input  wire             m_axi_bready  ,           

    input  wire [31 : 0]    m_axi_araddr  ,           
    input  wire [2 : 0]     m_axi_arprot  ,           
    input  wire             m_axi_arvalid ,           
    output wire             m_axi_arready ,           

    output wire [31 : 0]    m_axi_rdata   ,           
    output wire [1 : 0]     m_axi_rresp   ,           
    output wire             m_axi_rvalid  ,           
    input  wire             m_axi_rready  , 
        
    output wire [18 : 0]    cfg_mgmt_addr        ,     
    output wire             cfg_mgmt_write       ,     
    output wire [31 : 0]    cfg_mgmt_write_data  ,     
    output wire [3 : 0]     cfg_mgmt_byte_enable ,     
    output wire             cfg_mgmt_read        ,     
    input  wire [31 : 0]    cfg_mgmt_read_data   ,     
    input  wire             cfg_mgmt_read_write_done                     
    );
    
    //
    localparam ST_IDLE = 4'b0000;
    localparam ST_AW   = 4'b0001;
    localparam ST_W    = 4'b0010;
    localparam ST_RESP = 4'b0011;
    localparam ST_AR   = 4'b0100;
    localparam ST_R    = 4'b0101;
    localparam ST_LAST = 4'b0110;

    // 
    reg [3:0]  state;
    reg [3:0]  state_nxt;
    reg [7:0]  delay_counter;
    reg [7:0]  delay_counter_nxt;
    reg [31:0] saved_addr;
    reg [31:0] saved_addr_nxt;
    reg [31:0] saved_wdata;
    reg [31:0] saved_wdata_nxt;
    reg [31:0] saved_rdata;
    reg [31:0] saved_rdata_nxt;
    wire        timeout;
    // output
    assign m_axi_awready = (state==ST_AW);
    assign m_axi_wready  = 1'b1;
    assign m_axi_bresp   = 2'b00;
    assign m_axi_bvalid  = (state==ST_RESP);
    assign m_axi_arready = (state==ST_AR);

    assign m_axi_rdata   = saved_rdata;           
    assign m_axi_rresp   = 2'b00;           
    assign m_axi_rvalid  = (state==ST_LAST);           
    //
    assign cfg_mgmt_addr        = saved_addr;
    assign cfg_mgmt_write       = (state==ST_RESP);     
    assign cfg_mgmt_write_data  = saved_wdata;     
    assign cfg_mgmt_byte_enable = 4'hF;     
    assign cfg_mgmt_read        = m_axi_arvalid&&m_axi_arready;    
    
    
    assign timeout = &delay_counter;
    // 1.
    always @(*)
    begin
        state_nxt = state; 
        case(state)
        ST_IDLE :   begin
                    if(m_axi_awvalid)       state_nxt = ST_AW;
                    else if(m_axi_arvalid)  state_nxt = ST_AR;
                    else                    state_nxt = ST_IDLE;
                    end
        ST_AW   :   begin
                    if(m_axi_awvalid&&m_axi_awready) state_nxt = ST_W;
                    else                             state_nxt = ST_AW;
                    end
        ST_W    :   begin
                    if(m_axi_wvalid) state_nxt = ST_RESP;
                    else             state_nxt = ST_W;
                    end
        ST_RESP :   begin
                    state_nxt = ST_IDLE;
                    end
        ST_AR   :   begin
                    if(m_axi_arvalid&&m_axi_arready) state_nxt = ST_R;
                    else                             state_nxt = ST_AR;
                    end
        ST_R    :   begin
                    if(cfg_mgmt_read_write_done) state_nxt = ST_LAST;
                    else if (timeout)            state_nxt = ST_LAST;
                    else                         state_nxt = ST_R;
                    end
        ST_LAST :   begin
                    if(m_axi_rready) state_nxt = ST_IDLE;
                    end
        default :   begin
                    end
        endcase

    end
    // 2.
    always @(*)
    begin
        delay_counter_nxt = delay_counter;
        saved_addr_nxt    = saved_addr;
        saved_wdata_nxt   = saved_wdata;
        saved_rdata_nxt   = saved_rdata;

        case(state)
        ST_IDLE :   begin
                    delay_counter_nxt = 8'h0;
                    saved_addr_nxt    = 32'h0;
                    saved_wdata_nxt   = 32'h0;
                    saved_rdata_nxt   = 32'h0;
                    end
        ST_AW   :   begin
                    saved_addr_nxt    = m_axi_awaddr;
                    end
        ST_W    :   begin
                    saved_wdata_nxt   = m_axi_wdata;
                    end
        ST_RESP :   begin
                    end
        ST_AR   :   begin
                    saved_addr_nxt    = m_axi_araddr;
                    end
        ST_R    :   begin
                    if(&delay_counter)  delay_counter_nxt = delay_counter;
                    else                delay_counter_nxt = delay_counter + 1'b1;
                    if(cfg_mgmt_read_write_done)
                        saved_rdata_nxt = cfg_mgmt_read_data;
                    else if(timeout)
                        saved_rdata_nxt = 32'hFFFF_FFFF;
                    else 
                        saved_rdata_nxt = 32'h0000_0000;
                    end
        ST_LAST :   begin
                    end
        default :   begin
                    end
        endcase

    end
    // 3.
    always @(posedge aclk or negedge aresetn)
    if(~aresetn) begin
        state           <= 4'h0;
        delay_counter   <= 8'h0;
        saved_addr      <= 32'h0;
        saved_wdata     <= 32'h0;
        saved_rdata     <= 32'h0;
    end
    else begin
        state           <= state_nxt     ;
        delay_counter   <= delay_counter_nxt ;
        saved_addr      <= saved_addr_nxt    ;
        saved_wdata     <= saved_wdata_nxt   ;
        saved_rdata     <= saved_rdata_nxt   ;
    end
    
    
endmodule
