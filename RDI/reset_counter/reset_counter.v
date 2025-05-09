module reset_counter (
    input               i_clk,
    input               i_rst_n,
    input               i_count_en,
    input               i_clk_div_ratio, // 0h: 800M/(8) = 100MHz, 1h: 800MHz/(4) = 200MHz 
    output              o_reset_count_done
);
/********************************************
 * PARAMETERS
********************************************/
localparam COUNTING_4ms_USING_100mhz = 400;// 400000: number of clock cycles representing 4ms using 100 MHz clock
localparam COUNTING_4ms_USING_200mhz = 800;// 800000: number of clock cycles representing 4ms using 200 MHz clock
/*******************************************
 * INTERNAL WIRES/REGISTERS
*******************************************/
reg [19:0] reset_counter;
/*******************************************
 * ASSIGN/WIRE STATMENTS
*******************************************/
wire continue_counting = (~i_clk_div_ratio && reset_counter < COUNTING_4ms_USING_100mhz)? 1 : (i_clk_div_ratio && reset_counter < COUNTING_4ms_USING_200mhz)? 1 : 0;
/********************************************
 * COUNTER LOGIC
********************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        reset_counter <= 0;
    end else if (~i_count_en) begin
        reset_counter <= 0;
    end else if (continue_counting) begin 
        reset_counter <= reset_counter + 1;
    end 
end

assign o_reset_count_done = ((~i_clk_div_ratio && reset_counter == COUNTING_4ms_USING_100mhz) || (i_clk_div_ratio && reset_counter == COUNTING_4ms_USING_200mhz))? 1 : 0;

endmodule 