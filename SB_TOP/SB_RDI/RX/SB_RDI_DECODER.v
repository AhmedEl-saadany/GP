module SB_RDI_DECODER (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,          // should not be a gated one
    input               i_rst_n,    
    // credit loop control related signals
    input               i_adapter_is_full,
    // RDI related signals
    input               i_clk_is_ungated, // 34an lw el clock gated lazm afdl raf3 el msg_valid l7d mt2kd en el clock b2et 3nd el FSM 34an y samplha
    input               i_adapter_is_waked_up,
    // RX DESER related signals
    input               i_deser_done,
    input       [63:0]  i_deser_data,
/**************************************
 * OUTPUTS
**************************************/
    // credit loop control related signals
    output              o_rising_edge_pl_cfg_vld,
    // RX DESER related signals
    output              o_deser_done_sampled,
    // adapter related signals
    output reg [31:0]   o_pl_cfg,
    output reg          o_pl_cfg_vld,
    output              o_pl_nerror,    
    // RDI FSM related signals 
    output reg          o_wake_adapter,
    output reg          o_msg_valid,
    output reg  [3:0]   o_msg_no
);
/********************************************************************************
* PARAMETERS
********************************************************************************/
// Constants
localparam [1:0]  dstid_phy   = 2'b10; 
localparam [1:0]  dstid_d2d   = 2'b01; 
localparam [4:0]  opcode_msg_without_data  = 5'b10010; 
localparam [4:0]  opcode_msg_with_data     = 5'b11011;
/********************************************************************************
* INTERNAL WIRES AND REGISTERS
********************************************************************************/
reg [2:0] CS,NS;
reg [1:0] decoded_opcode;
reg clk_is_ungated_reg;
reg header_phase0_is_sent;
reg header_phase1_is_sent;
reg data_phase0_is_sent;
reg deser_done_reg;
reg pl_cfg_vld_reg;
// FIFO related signals
reg fifo_wr_en;
reg fifo_rd_en;
wire fifo_empty;
wire fifo_full;
wire [63:0] fifo_data_out;
/********************************************************************************
* RX FIFO INSTANCE
********************************************************************************/
SB_RX_FIFO SB_RDI_RX_FIFO (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_write_enable     (fifo_wr_en),
    .i_read_enable      (fifo_rd_en),
    .i_data_in          (i_deser_data),
    .o_data_out         (fifo_data_out),
    .o_empty            (fifo_empty),
    .o_full             (fifo_full)
);
/********************************************************************************
* FSM STATES
********************************************************************************/
localparam [2:0]    IDLE         = 3'b000,
                    FIFO_READ    = 3'b001,
                    DECODING     = 3'b011,
                    RDI_MSG      = 3'b010,
                    ADAPTER_MSG  = 3'b110,
                    ERROR_REPORT = 3'b111,
                    MSG_WITHOUT_DATA = 3'b101,
                    MSG_WITH_DATA    = 3'b100;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
wire [7:0] msgcode    = fifo_data_out[21:14]; // phase_0[21:14]
wire [7:0] msgsubcode = fifo_data_out[39:32]; // phase_1[7:0] 
wire [2:0] dstid      = fifo_data_out[58:56]; // phase_1[26:24]
wire falling_edge_pl_cfg_vld    = ~o_pl_cfg_vld & pl_cfg_vld_reg;
assign o_rising_edge_pl_cfg_vld = o_pl_cfg_vld & ~pl_cfg_vld_reg;
wire rising_edge_deser_done  = i_deser_done & ~deser_done_reg;
assign o_deser_done_sampled  = fifo_wr_en;
assign o_pl_nerror = (CS == ERROR_REPORT);
/********************************************************************************
* STATE MEMORY
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        CS <= IDLE;
        deser_done_reg <= 1'b0;
        pl_cfg_vld_reg <= 1'b0;
        clk_is_ungated_reg <= 1'b0;
    end else begin
        CS <= NS;
        deser_done_reg <= i_deser_done; 
        pl_cfg_vld_reg <= o_pl_cfg_vld;
        clk_is_ungated_reg <= i_clk_is_ungated; // this is a clock cycle delay to make sure that clock is ungated if it was
    end
end 
/********************************************************************************
* NEXT STATE LOGIC
********************************************************************************/
always @ (*) begin
    case (CS)
/*-------------------------------------------------------------------------------
 * IDLE state
-------------------------------------------------------------------------------*/
        IDLE: begin
            if (~fifo_empty) begin
                NS =  FIFO_READ;
            end else begin
                NS = IDLE;
            end
        end
/*-------------------------------------------------------------------------------
 * READ state
-------------------------------------------------------------------------------*/
        FIFO_READ: begin
            NS = DECODING; // just waiting to read from fifo
        end
/*-------------------------------------------------------------------------------
 * DECODING state
-------------------------------------------------------------------------------*/
        DECODING: begin
            if (dstid [1:0] == dstid_phy) begin
                NS = RDI_MSG;
            end else if (dstid [1:0] == dstid_d2d && ~i_adapter_is_full && i_adapter_is_waked_up) begin
                NS = ADAPTER_MSG;
            end else if (dstid [1:0] != dstid_d2d && dstid [1:0] != dstid_phy) begin
                NS = ERROR_REPORT;  
            end else begin
                NS = DECODING; 
            end
        end
/*-------------------------------------------------------------------------------
 * RDI_MSG state
-------------------------------------------------------------------------------*/
        RDI_MSG: begin
            if (~o_msg_valid) begin
                NS = IDLE;
            end else begin
                NS = RDI_MSG;
            end
        end
/*-------------------------------------------------------------------------------
 * ADAPTER_MSG state
-------------------------------------------------------------------------------*/
        ADAPTER_MSG: begin
            if (fifo_data_out[4:0] == opcode_msg_without_data) begin
                NS = MSG_WITHOUT_DATA;
            end else if (fifo_data_out[4:0] == opcode_msg_with_data) begin
                NS = MSG_WITH_DATA;
            end else begin // since we are not supporting managment transport protocol 
                NS = ERROR_REPORT;
            end
        end
/*-------------------------------------------------------------------------------
 * MSG_WITHOUT_DATA state
-------------------------------------------------------------------------------*/
        MSG_WITHOUT_DATA: begin
            if (falling_edge_pl_cfg_vld) begin
                NS = IDLE;
            end else begin
                NS = MSG_WITHOUT_DATA;
            end   
        end
/*-------------------------------------------------------------------------------
 * MSG_WITH_DATA state
-------------------------------------------------------------------------------*/
        MSG_WITH_DATA: begin
            if (falling_edge_pl_cfg_vld) begin
                NS = IDLE;
            end else begin
                NS = MSG_WITH_DATA;
            end   
        end
/*-------------------------------------------------------------------------------
 * ERROR_REPORT state
-------------------------------------------------------------------------------*/
        ERROR_REPORT: begin
            if (i_adapter_is_waked_up) begin // counter finished after 3 clk cycles
                NS = IDLE;
            end else begin
                NS = ERROR_REPORT;
            end
        end
        default: NS = IDLE;
    endcase
end
/********************************************************************************
* OUTPUT LOGIC FOR ADAPTER MESSAGES
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        fifo_wr_en   <= 1'b0;
        fifo_rd_en   <= 1'b0;
        o_pl_cfg     <= {32{1'b0}};
        o_pl_cfg_vld <= 1'b0;
        header_phase0_is_sent <= 1'b0;
        header_phase1_is_sent <= 1'b0;
        data_phase0_is_sent   <= 1'b0;
        o_wake_adapter <= 1'b0;
        //decoded_opcode <= 2'b00;
    end else begin
        fifo_wr_en <= 0; // to make sure i "write" for only one clock cycle
        fifo_rd_en <= 0; // to make sure i "read"  for only one clock cycle
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // writing conditions
        fifo_wr_en <= (rising_edge_deser_done & ~fifo_full); 
        // reading conditions
        fifo_rd_en <= (CS == IDLE && NS == FIFO_READ);
        // waking adapter if adapter message is found or error found
        o_wake_adapter <= (CS == DECODING && (NS == DECODING || NS == ADAPTER_MSG || NS == ERROR_REPORT))? 1 : (CS == ADAPTER_MSG && NS == ERROR_REPORT)? 1 : (i_adapter_is_waked_up)? 0 : o_wake_adapter;
        case (CS)
        /**********************************************
         * message without data
        **********************************************/
            MSG_WITHOUT_DATA: begin
            /*----------------------
             * PHASE 0 HEADER
            -----------------------*/
                if (~o_pl_cfg_vld && |NS) begin
                    o_pl_cfg <= fifo_data_out[31:0];
                    o_pl_cfg_vld   <= 1'b1;
                    header_phase0_is_sent <= 1'b1;
            /*----------------------
            * PHASE 1 HEADER
            -----------------------*/
                end else if (header_phase0_is_sent) begin
                    o_pl_cfg <= fifo_data_out[63:32];
                    header_phase0_is_sent <= 1'b0;
                end else begin
                    o_pl_cfg <= {32{1'b0}};
                    o_pl_cfg_vld <= 1'b0;
                end
            end
        /**********************************************
         * message with data
        **********************************************/
            MSG_WITH_DATA: begin
            /*----------------------
             * PHASE 0 HEADER
            -----------------------*/
            if (~o_pl_cfg_vld && ~fifo_empty) begin
                o_pl_cfg <= fifo_data_out[31:0];
                o_pl_cfg_vld   <= 1'b1;
                header_phase0_is_sent <= 1'b1;
                fifo_rd_en     <= 1'b1;
            end 
            /*----------------------
            * PHASE 1 HEADER
            -----------------------*/
            else if (header_phase0_is_sent) begin
                o_pl_cfg <= fifo_data_out[63:32];
                header_phase1_is_sent <= 1'b1;
                header_phase0_is_sent <= 1'b0;
                fifo_rd_en     <= 1'b0;
            end 
            /*----------------------
             * PHASE 0 DATA
            -----------------------*/
            else if (header_phase1_is_sent) begin
                o_pl_cfg <= fifo_data_out[31:0];
                data_phase0_is_sent <= 1'b1;
                header_phase1_is_sent <= 1'b0;
            /*----------------------
             * PHASE 1 DATA
            -----------------------*/
            end else if (data_phase0_is_sent) begin
                o_pl_cfg <= fifo_data_out[63:32];
                data_phase0_is_sent <= 1'b0;
            end else begin
                o_pl_cfg <= {32{1'b0}};
                o_pl_cfg_vld <= 1'b0; 
            end               
            end
            default: begin
                o_pl_cfg <= {32{1'b0}};
                o_pl_cfg_vld <= 1'b0;
            end
        endcase
    end
end 
/********************************************************************************
* OUTPUT LOGIC FOR RDI MESSAGES
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_msg_no <= 4'b0000;
        o_msg_valid <= 1'b0;
    end else if (CS == DECODING && NS == RDI_MSG) begin
        o_msg_valid <= 1'b1;
        case (msgcode)
            8'h01: begin
                case (msgsubcode)
                    8'h01: begin
                        o_msg_no <= 4'd1;                           
                    end
                    8'h04: begin
                        o_msg_no <= 4'd2;                            
                    end
                    8'h08: begin
                        o_msg_no <= 4'd3;                            
                    end
                    8'h09: begin
                        o_msg_no <= 4'd4;                            
                    end
                    8'h0A: begin
                        o_msg_no <= 4'd5;                           
                    end
                    8'h0B: begin
                        o_msg_no <= 4'd6;                            
                    end
                    8'h0C: begin
                        o_msg_no <= 4'd7;                            
                    end
                    default: begin                      
                        o_msg_no <= 4'b0000;
                        o_msg_valid <= 1'b0;
                    end
                endcase
            end
            /*----------------------------------------------------------------*/
            8'h02: begin
                case (msgsubcode)
                    8'h01: begin
                        o_msg_no <= 4'd8;                           
                    end
                    8'h02: begin
                        o_msg_no <= 4'd9;                           
                    end
                    8'h04: begin
                        o_msg_no <= 4'd10;                            
                    end
                    8'h08: begin
                        o_msg_no <= 4'd11;                            
                    end
                    8'h09: begin
                        o_msg_no <= 4'd12;                            
                    end
                    8'h0A: begin
                        o_msg_no <= 4'd13;                           
                    end
                    8'h0B: begin
                        o_msg_no <= 4'd14;                            
                    end
                    8'h0C: begin
                        o_msg_no <= 4'd15;                            
                    end
                    default: begin                      
                        o_msg_no <= 4'b0000;
                        o_msg_valid <= 1'b0;
                    end
                endcase
            end
            default: begin
                o_msg_no <= 4'b0000;
                o_msg_valid <= 1'b0;
            end
        endcase
    end else if (clk_is_ungated_reg) begin
        o_msg_valid <= 1'b0;
    end
end
endmodule 
