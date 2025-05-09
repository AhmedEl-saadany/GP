module SB_RDI_ENCODER (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,          // should be a gated one
    input               i_rst_n,    
    // Adapter related signals
    input               i_lp_cfg_vld,
    input   [31:0]      i_lp_cfg,
    // RDI FSM related signals
    input   [3:0]       i_msg_no,
    input               i_msg_valid,
    input               i_adapter_is_waked_up,
    // TX FIFO related signals
    input               i_fifo_full,
/**************************************
 * OUTPUTS
**************************************/
    // adapter related signals
    output              o_pl_nerror,
    // RDI FSM related signals 
    output              o_msg_done,
    output reg          o_wake_adapter,
    // TX FIFO related signals
    output reg [63:0]   o_fifo_data,
    output reg          o_delete_data, // goes to fifo to delete data written by mistake when error found late
    output reg          o_fifo_write_en // till now it will work as done 
);
/********************************************************************************
* PARAMETERS
********************************************************************************/
// Constants
localparam [4:0]  opcode_msg_without_data  = 5'b10010; 
localparam [4:0]  opcode_msg_with_data     = 5'b11011;
localparam [2:0]  srcid   = 3'b010; 
localparam [2:0]  dstid   = 3'b110; 
localparam [15:0] msginfo = 16'h0000;
localparam rsvd = 1'b0;
localparam dp   = 1'b0; // No data parity since there is no data to send
/********************************************************************************
* INTERNAL WIRES AND REGISTERS
********************************************************************************/
// packets phases
reg [31:0] phase_0;
reg [31:0] phase_1;
reg [2:0]  CS,NS;
reg [2:0]  shift_counter;
reg is_data;
reg send_128_zero;
/********************************************************************************
* FSM STATES
********************************************************************************/
localparam [2:0]    DECODING                = 3'b000,
                    HEADER_PHASE0_CAPTURED  = 3'b001,
                    HEADER_PHASE1_CAPTURED  = 3'b011,
                    DATA_PHASE0_CAPTURED    = 3'b010,
                    DATA_PHASE1_CAPTURED    = 3'b110,
                    ERROR_REPORT            = 3'b111, // &CS = 1 in this state onlyyyy
                    RDI_MSG                 = 3'b101;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
assign o_pl_nerror = (CS == ERROR_REPORT);
assign o_msg_done  = (CS == RDI_MSG)? o_fifo_write_en : 0;
//assign o_delete_data = ((CS == HEADER_PHASE1_CAPTURED || CS == DATA_PHASE0_CAPTURED) && NS == ERROR_REPORT);
/********************************************************************************
* STATE MEMORY
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        CS <= DECODING;
    end else begin
        CS <= NS;
    end
end 
/********************************************************************************
* NEXT STATE LOGIC
********************************************************************************/
always @ (*) begin
    case (CS)
/*-------------------------------------------------------------------------------
 * DECODING state
-------------------------------------------------------------------------------*/
        DECODING: begin
            if (i_lp_cfg_vld && (i_lp_cfg[4:0] == opcode_msg_without_data || i_lp_cfg[4:0] == opcode_msg_with_data)) begin 
                NS = HEADER_PHASE0_CAPTURED;
            end else if (i_lp_cfg_vld && (i_lp_cfg[4:0] != opcode_msg_without_data && i_lp_cfg[4:0] != opcode_msg_with_data)) begin
                NS = ERROR_REPORT;
            end else if (i_msg_valid) begin
                NS = RDI_MSG;
            end else begin
                NS = DECODING;
            end
        end
/*-------------------------------------------------------------------------------
 * RDI_MSG state
-------------------------------------------------------------------------------*/
        RDI_MSG: begin
            if (o_msg_done) begin
                NS = DECODING;
            end else begin
                NS = RDI_MSG;
            end
        end
/*-------------------------------------------------------------------------------
 * HEADER_PHASE0_CAPTURED state
-------------------------------------------------------------------------------*/
        HEADER_PHASE0_CAPTURED: begin
            if (i_lp_cfg_vld) begin
                NS = HEADER_PHASE1_CAPTURED;
            end else begin
                NS = ERROR_REPORT; // since i_lp_cfg_vld should be raised even no. of cycles 2,4,6,... since smallest packet is msg_with_no_data 64 bits sent on 2 phases
            end
        end
/*-------------------------------------------------------------------------------
 * HEADER_PHASE1_CAPTURED state
-------------------------------------------------------------------------------*/
        HEADER_PHASE1_CAPTURED: begin
            if (~i_lp_cfg_vld && ~is_data) begin  // y2ma msh hyb2a fii valid w harg3 ll decode state
                NS = DECODING;
            end else if (~i_lp_cfg_vld && is_data) begin // error 34an kan el mafrood yb2a fi data (3rft mn el decoding) bas el valid nzlt
                NS = ERROR_REPORT;
            end else if (is_data) begin // y2ma hyb2a fi valid w data fa el next state is capturing the 64 bits of data
                NS = DATA_PHASE0_CAPTURED;
            end else if ((i_lp_cfg [4:0] == opcode_msg_without_data || i_lp_cfg [4:0] == opcode_msg_with_data)) begin // y2ma hyb2a fi valid w mafish data adeema fa hatkon msg gdeeda sa3tha 
                NS = HEADER_PHASE0_CAPTURED;
            end else begin // lw el valid marfoo3a w mafish data adeema w el opcode bta3 el message el gdeeda msh haga mn dool yb2a kdh khalas error ana m3rfsh eh el msg di
                NS = ERROR_REPORT;
            end 
        end
/*-------------------------------------------------------------------------------
 * DATA_PHASE0_CAPTURED state
-------------------------------------------------------------------------------*/
        DATA_PHASE0_CAPTURED: begin
            if (i_lp_cfg_vld) begin
                NS = DATA_PHASE1_CAPTURED;
            end else begin
                NS = ERROR_REPORT; // since i_lp_cfg_vld should be raised even no. of cycles 2,4,6,... since smallest packet is msg_with_no_data 64 bits sent on 2 phases
            end
        end
/*-------------------------------------------------------------------------------
 * DATA_PHASE1_CAPTURED state
-------------------------------------------------------------------------------*/
        DATA_PHASE1_CAPTURED: begin
            if (~i_lp_cfg_vld) begin
                NS = DECODING;
            end else if ((i_lp_cfg [4:0] == opcode_msg_without_data || i_lp_cfg [4:0] == opcode_msg_with_data)) begin // y2ma hyb2a fi valid fa hatkon msg gdeeda sa3tha 
                NS = HEADER_PHASE0_CAPTURED;
            end else begin // lw el valid marfoo3a w mafish data adeema w el opcode bta3 el message el gdeeda msh haga mn dool yb2a kdh khalas error ana m3rfsh eh el msg di
                NS = ERROR_REPORT;
            end 
        end
/*-------------------------------------------------------------------------------
 * ERROR_REPORT state
-------------------------------------------------------------------------------*/
        ERROR_REPORT: begin
            if (i_adapter_is_waked_up) begin // counter finished after 3 clk cycles
                NS = DECODING;
            end else begin
                NS = ERROR_REPORT;
            end
        end
        default: NS = DECODING;
    endcase
end
/********************************************************************************
* OUTPUT LOGIC
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_fifo_write_en <= 1'b0;
        o_fifo_data     <= {64{1'b0}};
        is_data         <= 1'b0;
        o_wake_adapter  <= 1'b0;
        send_128_zero   <= 1'b0;
        o_delete_data   <= 1'b0;
    end else begin
        // waking adapter if error found
        o_wake_adapter  <= (~&CS && NS == ERROR_REPORT)? 1 : (i_adapter_is_waked_up)? 0 : o_wake_adapter;
        // deleting data written in fifo by mistake if error is found late
        o_delete_data   <= ((CS == HEADER_PHASE1_CAPTURED || CS == DATA_PHASE0_CAPTURED) && NS == ERROR_REPORT);
        o_fifo_write_en <= (~send_128_zero)? 1'b0 : o_fifo_write_en; // always reset before entering any condition to raise for only one clock cycle
        // el condition eli foo2 dh m3nah lw send_128_zero marfoo3 fa estna mtnzlsh el write en 3ala tool estna lma nrg3 decoding lakn lw msh marfoo3 nzl el write en 3ala tool
        // estna lma nrg3 decoding di hatdeelo extra clock cycle marfoo3 fiha el write en 34an yktb el zeros marten
        /***************************************************************************************************************************************************
         * ADDING ZEROS AFTER MSG WITHOUT DATA
        ****************************************************************************************************************************************************/
        if (CS == HEADER_PHASE1_CAPTURED && NS == DECODING) begin
            o_fifo_data [63:0] <= {64{1'b0}};
            o_fifo_write_en <= 1;
        end 
        //////////////////////////////////////////////////////////
        if (CS == DECODING) begin
            send_128_zero <= 1'b0;
        end
        /***************************************************************************************************************************************************/
        //////////////////////////////// SENDING RDI MSG ////////////////////////////////////////
        if (CS == DECODING && NS == RDI_MSG) begin
            o_fifo_data     <= {phase_1,phase_0};
            o_fifo_write_en <= (~i_fifo_full); // writing data in fifo after encoding msg no from RDI and making sure that the fifo is not full
        end   
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == DECODING && NS == HEADER_PHASE0_CAPTURED) begin
            is_data <= (i_lp_cfg [4:0] == opcode_msg_without_data)? 0 : (i_lp_cfg [4:0] == opcode_msg_with_data)? 1 : is_data;
            o_fifo_data [31:0] <= i_lp_cfg; // capturing phase "zero" of header
        end 
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == HEADER_PHASE0_CAPTURED && NS == HEADER_PHASE1_CAPTURED) begin
            o_fifo_data [63:32] <= i_lp_cfg; // capturing phase "one" of header
            o_fifo_write_en     <= 1'b1;     // writing data in fifo after capturing all header
        end
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == HEADER_PHASE1_CAPTURED && NS == DATA_PHASE0_CAPTURED) begin
            o_fifo_data [31:0] <= i_lp_cfg; // capturing phase "zero" of data
        end
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == DATA_PHASE0_CAPTURED && NS == DATA_PHASE1_CAPTURED) begin
            o_fifo_data [63:32] <= i_lp_cfg; // capturing phase "one" of data
            o_fifo_write_en     <= 1'b1;     // writing data in fifo after capturing all data
        end
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == HEADER_PHASE1_CAPTURED && NS == HEADER_PHASE0_CAPTURED) begin // new message 
            is_data <= (i_lp_cfg [4:0] == opcode_msg_without_data)? 0 : (i_lp_cfg [4:0] == opcode_msg_with_data)? 1 : is_data;
            o_fifo_data [31:0] <= i_lp_cfg; // capturing phase "zero" of d (new msg without data header)
            send_128_zero <= 1;
        end
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (CS == DATA_PHASE1_CAPTURED && NS == HEADER_PHASE0_CAPTURED) begin // new message
            is_data <= (i_lp_cfg [4:0] == opcode_msg_without_data)? 0 : (i_lp_cfg [4:0] == opcode_msg_with_data)? 1 : is_data;
            o_fifo_data [31:0] <= i_lp_cfg; // capturing phase "zero" of data (new msg without data header)
        end
    end
end 
/********************************************************************************
* ENCODING  (Hint: All RDI messages are without data )
********************************************************************************/
always @ (*) begin
    phase_0 = {32{1'b0}};
    phase_1 = {32{1'b0}};
/*---------------------------------------
 * Sending RDI FSM Msg
----------------------------------------*/
// Note: All cp here is calculated manaully
    case (i_msg_valid)
        1'b1: begin
            case (i_msg_no)
                4'd1: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h01};                           
                end
                4'd2: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h04};                            
                end
                4'd3: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h08};                            
                end
                4'd4: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h09};                            
                end
                4'd5: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h0A};                           
                end
                4'd6: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h0B};                            
                end
                4'd7: begin
                    phase_0 = {srcid,{7{rsvd}},8'h01,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h0C};                            
                end
                4'd8: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h01};                            
                end
                4'd9: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h02};                            
                end
                4'd10: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h04};                           
                end
                4'd11: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h08};                            
                end
                4'd12: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h09};                            
                end

                4'd13: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h0A};                            
                end
                4'd14: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b1,{3{rsvd}},dstid,{16{rsvd}},8'h0B};                           
                end
                4'd15: begin
                    phase_0 = {srcid,{7{rsvd}},8'h02,{9{rsvd}},opcode_msg_without_data};
                    phase_1 = {dp,1'b0,{3{rsvd}},dstid,{16{rsvd}},8'h0C};                           
                end
                default: begin                      
                    phase_0 = {32{1'b0}};
                    phase_1 = {32{1'b0}};
                end
            endcase
        end
        /*----------------------------------------------------------------*/
        1'b0: begin
            phase_0 = {32{1'b0}};
            phase_1 = {32{1'b0}};
        end
    endcase
end

endmodule 