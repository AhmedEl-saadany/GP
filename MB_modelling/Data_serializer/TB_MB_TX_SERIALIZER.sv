`timescale 1ps/100fs
module TB_MB_TX_SERIALIZER ;
localparam DATA_WIDTH = 32;

logic							i_ser_clk_4G;
logic                           dig_clk;
logic							RST;
logic	[DATA_WIDTH-1:0] 		P_DATA;
logic							SER_EN;
logic 						    SER_OUT;
logic   [DATA_WIDTH-1:0]        o_deser_data_out;
logic                           o_deser_data_valid;

MB_TX_SERIALIZER u_SER (
    .CLK        (i_ser_clk_4G),
    .RST        (RST),
    .P_DATA     (P_DATA),
    .SER_EN     (SER_EN),
    .SER_OUT    (SER_OUT)
);

MB_RX_DESER  u_DESER(
    .i_clk_async            (i_ser_clk_4G & SER_EN),
    .i_clk_sync             (dig_clk),
    .i_rst_n                (RST),
    .i_ser_data_in          (SER_OUT),
    .o_deser_data_out       (o_deser_data_out),
    .o_deser_data_valid     (o_deser_data_valid)
);

clock_div_32 clock_div_32_inst_1 (
    .i_clk             (i_ser_clk_4G),
    .i_rst_n           (RST),
    .o_div_clk         (dig_clk)
);  

 initial begin
    i_ser_clk_4G = 0;
    forever #125 i_ser_clk_4G = ~i_ser_clk_4G; // 0.25ns period = 4GHz
 end


initial begin
    RST = 0;
    P_DATA = 'b0;
    SER_EN = 0;
    DELAY (3);
    RST = 1;
    SER_EN = 1;
    for (int i =0;i<4;i++) begin
        P_DATA = $urandom;
        DELAY (32);
    end
    DELAY (5);
    $stop;
end




/**********************************
* delay task 
**********************************/
task DELAY (input integer delay);
    repeat (delay) @(posedge i_ser_clk_4G);
endtask

endmodule