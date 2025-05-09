module SB_RX_FIFO (
    input 			 	 i_clk,                // Input clock from clock divider (100 MHz)    
    input 				 i_rst_n,              // Active-low reset     
    input 		    	 i_write_enable,       // Write enable in fifo
    input                i_read_enable,        // Read enable from fifo
    input 	   [63:0]	 i_data_in,            // Data to be written in fifo
    output reg [63:0] 	 o_data_out,           // Data to be read from fifo
    output reg 			 o_empty,              // Empty flag for fifo
    output               o_full                // Full flag for fifo
);

/*------------------------------------------------------------------------------
-- INTERNAL WIRES & REGS   
------------------------------------------------------------------------------*/
reg [63:0] memory [0:3];
reg [2:0] write_count;
reg [2:0] read_count;
wire o_empty_comb;
reg [2:0] loop_counter;

/*------------------------------------------------------------------------------
-- Combinational output logic  
------------------------------------------------------------------------------*/
assign o_empty_comb = (write_count == read_count);
assign o_full = (write_count[1:0] == read_count[1:0] && write_count[2] != read_count[2]);

/*------------------------------------------------------------------------------
-- Sequential output for empty flag  
------------------------------------------------------------------------------*/
always @(posedge i_clk or negedge i_rst_n) begin 
    if(~i_rst_n) begin
        o_empty <= 1;
    end else begin
        o_empty <= o_empty_comb;
    end
end

/*------------------------------------------------------------------------------
-- Write Operation  
------------------------------------------------------------------------------*/
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        write_count <= 0;
        for (loop_counter = 0; loop_counter <= 6'd3 ; loop_counter = loop_counter + 1) begin
            memory [loop_counter] <= {64{1'b0}};
        end
    end 
    else if (i_write_enable) begin
        memory[write_count[1:0]] <= i_data_in;
        write_count <= write_count + 1;
    end
end

/*------------------------------------------------------------------------------
-- Read Operation  
------------------------------------------------------------------------------*/
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        read_count <= 0;
        o_data_out <= 64'b0;
    end 
    else if (i_read_enable && ~o_empty_comb) begin
        o_data_out <= memory[read_count[1:0]];
        read_count <= read_count + 1;
    end
end

endmodule
