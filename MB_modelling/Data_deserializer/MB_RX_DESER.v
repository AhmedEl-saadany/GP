module MB_RX_DESER (
    input               i_clk_async,
    input               i_clk_sync,
    input               i_rst_n,
    input               i_ser_data_in,
    output reg [31:0]   o_deser_data_out,
    output reg          o_deser_data_valid
);


reg [31:0] deser_data_temp_1;
reg [4:0] counter;
reg count_done;
reg q1;

always @ (posedge i_clk_async or negedge i_rst_n) begin
    if (~i_rst_n) begin
        deser_data_temp_1 <= 'b0;
        counter <= 0;
        count_done <= 0;
    end else begin
        deser_data_temp_1 <= {i_ser_data_in,deser_data_temp_1[31:1]};
        counter <= counter +1;
        count_done <= (&counter);
    end
end

always @ (posedge i_clk_async or negedge i_rst_n) begin
     if (~i_rst_n) begin
        o_deser_data_out <= 'b0;
    end else begin
        if (count_done)
        o_deser_data_out <= deser_data_temp_1;
    end
end   

// synchronizing deser valid
always @ (posedge i_clk_sync or negedge i_rst_n) begin
     if (~i_rst_n) begin
        q1 <= 0;
        o_deser_data_valid <= 0;
    end else begin
        q1 <= count_done;
        o_deser_data_valid <= q1;
    end
end 

endmodule 