module selfcal_rx  (
	//inputs 
		input clk,    // Clock
		input rst_n,  // Asynchronous reset active low
		input i_en,
		//communcating with sideband 
		input [3:0]  i_decoded_sideband_message ,
		//handling_mux_priorities 
		input        i_busy_negedge_detected,i_valid_tx,
	//output 
		//communcting with sideband
		output reg [3:0] o_sideband_message,
		output reg       o_valid_rx,
		//finishing ack
		output reg o_test_ack
);
/*------------------------------------------------------------------------------
--fsm states   
------------------------------------------------------------------------------*/
parameter IDLE =0;
parameter WAIT_FOR_END_REQ=1;
parameter SEND_END_RESPONSE=2;
parameter TEST_FINISHED=3;
/*------------------------------------------------------------------------------
--variables declaration   
------------------------------------------------------------------------------*/
reg [1:0] cs,ns ;
wire valid_cond,valid_negedge_detected;
reg valid_should_go_high, valid_reg;
/*------------------------------------------------------------------------------
--assign statemnets   
------------------------------------------------------------------------------*/
assign valid_cond = cs[0] != ns[0] && (ns==SEND_END_RESPONSE);
assign valid_negedge_detected= ~o_valid_rx && valid_reg;
/*------------------------------------------------------------------------------
--current state update   
------------------------------------------------------------------------------*/
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cs<=IDLE;
	end else begin
		cs<=ns;
	end
end
/*------------------------------------------------------------------------------
--next state logic  
------------------------------------------------------------------------------*/
always @(*) begin
	case (cs)
		IDLE:begin
			if (i_en) begin
				ns=WAIT_FOR_END_REQ;
			end else begin
				ns=IDLE;
			end
		end
		WAIT_FOR_END_REQ:begin
			if (i_decoded_sideband_message==4'b0001) begin
				ns=SEND_END_RESPONSE;
			end else begin
				ns=WAIT_FOR_END_REQ;
			end
		end
		SEND_END_RESPONSE:begin
			if(valid_negedge_detected) begin
				ns=TEST_FINISHED;
			end else begin
				ns=SEND_END_RESPONSE;
			end
		end
		TEST_FINISHED:begin
			if (~i_en) begin
				ns=IDLE;
			end else begin
				ns=TEST_FINISHED;
			end
		end
		default: 
			ns=IDLE;
	endcase
end
/*------------------------------------------------------------------------------
--output logic  
------------------------------------------------------------------------------*/
always @(posedge clk or negedge rst_n) begin : proc_
	if(~rst_n) begin
		//constant 
		o_sideband_message<=0;
		o_test_ack<=0;
	end else begin
		case (cs)
			IDLE:begin
				o_sideband_message<=0;
				//test parameters 
				o_test_ack<=0;
			end
			WAIT_FOR_END_REQ:begin
				if(ns==SEND_END_RESPONSE)
					o_sideband_message<=4'b0010;
			end
			SEND_END_RESPONSE:begin
				if(ns==TEST_FINISHED) begin
					o_sideband_message<=4'b0000;
					o_test_ack<=1;
				end
			end
			TEST_FINISHED:begin
			end
			default : ;
		endcase
	end
end
 /*------------------------------------------------------------------------------
 --handling valid signal 
 ------------------------------------------------------------------------------*/
always @(posedge clk or negedge rst_n) begin : proc_o_valid_rx_rx
	if(~rst_n) begin
		o_valid_rx <= 0;
	end else if (i_busy_negedge_detected)begin
		o_valid_rx<=0;
	end else if ( ( valid_cond || valid_should_go_high )&& !i_valid_tx) begin
		o_valid_rx <= 1;
	end
end
always @(posedge clk or negedge rst_n) begin : proc_valid_should_go_high
	if(~rst_n) begin
		valid_should_go_high <= 0;
	end else if(valid_cond)begin
		valid_should_go_high <= 1;
	end else if(i_busy_negedge_detected && !i_valid_tx) begin
		valid_should_go_high<=0;
	end
end
always @(posedge clk or negedge rst_n) begin : proc_valid_reg
	if(~rst_n) begin
		valid_reg <= 0;
	end else begin
		valid_reg <=o_valid_rx ;
	end
end
endmodule 

