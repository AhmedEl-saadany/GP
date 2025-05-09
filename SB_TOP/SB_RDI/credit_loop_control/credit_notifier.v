module credit_notifier (
/**************************************
 * INPUTS
**************************************/
    input           i_clk,
    input           i_rst_n,
    // TX fifo related signals
    input           i_tx_fifo_read_en, // should be connected to o_ser_done_sampled
    input   [1:0]   i_srcid,           // should be connected to o_fifo_data [30:29]
    input           i_fifo_data_is_zeros, // should be connected to o_dont_send_zeros
    // o_dont_send_zeros: this flag is raised from fifo when the fifo_data_out is 64'b0 (it is the dummy data we put with header for adapter msg_witout_data
    // so that each msg_witout_data consumes 128 bits in fifo (64'b header and 64'b0))
    // we also need this flag here because if we relay on reading srcid only .. in such case like sending two msgs with no data consecutivley, we put them 
    // in fifo in this way (header(1) -> header(2) -> 64'b0 -> 64'b0) so when we read the srcid of header(1) we wait for another read which is will be
    // header(2) read and this two reads will release a credit but when we read the two zeros (note:we will not serialize them) the decoding of the srcid
    // will ont capture them thus it will not release a credit while it we should release two credits for the two headers .. so this flag used to enter
    // "ADAPTER_MSG" state (which we check on fifo read to release credits) in 2 case , 1st when we decode a srcid adapter, 2nd when data is zeros 
/**************************************
 * OUTPUTS
**************************************/
    // Adapter related signals
    output          o_pl_cfg_crd
);
/********************************************************************************
* PARAMETERS
********************************************************************************/
localparam [1:0]  srcid_phy   = 2'b10; // phy
localparam [1:0]  srcid_d2d   = 2'b01; // adapter
/********************************************************************************
* FSM STATES
********************************************************************************/
localparam IDLE = 1'b0;
localparam ADAPTER_MSG = 1'b1;
/********************************************************************************
* INTERNAL WIRES/REGISTERS
********************************************************************************/
reg [1:0] shift_counter;
reg read_en_reg;
reg CS,NS;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
assign o_pl_cfg_crd = (CS == ADAPTER_MSG && read_en_reg); // lw get hena fa enta gy w m3ak awel header already read aslun w ela mkunt4 dakhlt el state "ADAPTER_MSG" fanta kol eli me7tago tany hwa 
// read mara kaman wenta gwa el state nafsha b2a w erf3 credit b3diha w erg3 idle tany check for new messages
/********************************************************************************
* STATE MEMORY
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        CS <= IDLE;
    end else begin
        CS <= NS;
    end
end
/********************************************************************************
* NEXT STATE LOGIC
********************************************************************************/
always @ (*) begin
    case (CS)
        IDLE: begin
            if (read_en_reg && (i_srcid == srcid_d2d || i_fifo_data_is_zeros)) begin
                NS = ADAPTER_MSG;
            end else begin
                NS = IDLE;
            end
        end
        ADAPTER_MSG: begin // lw ana dakhelt el state di yb2a ana kdh 3amlt read ll header w l2eto srcid adapter fa kdh na fadl 22ra word kaman 34an a release credit ... go to line 35
            if (o_pl_cfg_crd) begin 
                NS = IDLE;
            end else begin
                NS = ADAPTER_MSG; 
            end
        end
    endcase
end
/**********************************************
 * READ EN PULSE SYNCHRONIZATION
**********************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        read_en_reg <= 1'b0;
    end else if (read_en_reg) begin
        read_en_reg <= 1'b0;
    end else begin
        read_en_reg <= i_tx_fifo_read_en;
    end
end
endmodule