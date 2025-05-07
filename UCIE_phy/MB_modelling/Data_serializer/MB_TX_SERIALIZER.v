module MB_TX_SERIALIZER (CLK,RST,P_DATA,SER_EN,SER_OUT);

parameter DATA_WIDTH = 32;
parameter COUNTER_WIDTH= 3'b101; // 3'd5

/*------------------ IN/OUT PORTS -----------------*/
input 							CLK;
input							RST;
input 	[DATA_WIDTH-1:0] 		P_DATA;
input 							SER_EN;
output reg 						SER_OUT;

/*----------------- COUNTER SIGNALS ---------------*/
reg [COUNTER_WIDTH-1:0] COUNTER;
reg [DATA_WIDTH-1:0] P_DATA_TEMP;
reg SER_EN_TEMP;
wire RISING_EDGE_SER_EN = SER_EN & ~SER_EN_TEMP;
reg COUNT_DN;

/*----------------- LOAD P_DATA  ---------------*/
always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		P_DATA_TEMP <= {DATA_WIDTH{1'b0}};
		SER_EN_TEMP <= 0;
	end else begin
		SER_EN_TEMP <= SER_EN;
		if (RISING_EDGE_SER_EN || COUNT_DN) begin
			P_DATA_TEMP <= P_DATA;
		end
	end
end

/*----------------- SERIALIZING DATA ---------------*/
always @(posedge CLK or negedge RST) begin 
	if(~RST) begin 
		COUNTER  <= 0; 
		COUNT_DN <= 0;
	end 
	else begin
		if(SER_EN) begin
			COUNT_DN <= (&COUNTER);
			SER_OUT <= P_DATA_TEMP[COUNTER];
			COUNTER <= COUNTER+1;
		end
		else  begin
			COUNTER <= 0;
			SER_OUT <= 0;
		end
	end
end

endmodule
