module delay_cell #(
    parameter DELAY_CYCLES = 4,
    parameter DATA_WIDTH   = 4
) (
    input                           i_clk,
    input                           i_rst_n,
    input       [DATA_WIDTH-1:0]    i_data,
    output      [DATA_WIDTH-1:0]    o_data
);

logic [DATA_WIDTH-1:0] delayed_signal [DELAY_CYCLES-1:0];


always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (int i = 0; i < DELAY_CYCLES; i = i + 1) begin 
            delayed_signal [i] <= 0;
        end
    end else begin
        for (int i = DELAY_CYCLES-1; i > 0; i = i - 1) begin
            delayed_signal [i] <= delayed_signal [i-1];
        end 
            delayed_signal [0] <= i_data;
    end
end

assign o_data = delayed_signal[DELAY_CYCLES-1];

endmodule 