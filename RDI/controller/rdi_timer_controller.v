module rdi_timer_controller (
    input               lclk,
    input               sys_rst,
    input               i_pm_timer_start,
    input               i_linkerror_timer_start,

    output reg          o_pm_timeout,
    output reg          o_linkerror_timeout
);

    // Timers
    localparam  MS_TO_CLK        = 100,           // 1us in clock cycles
                PM_TIMEOUT       = 2 * MS_TO_CLK,  // 2us timeout
                LINKERROR_TIMEOUT = 16 * MS_TO_CLK; // 16us timeout

    reg [11:0] linkerror_counter;
    reg [9:0]  pm_timeout_counter;
    
    // Timer logic
    always @(posedge lclk or negedge sys_rst) begin
        if (~sys_rst) begin
            // Reset counters and timeout signals
            linkerror_counter    <= 0;
            pm_timeout_counter   <= 0;
            o_linkerror_timeout  <= 1'b0;
            o_pm_timeout        <= 1'b0;
        end else begin
            // Default assignments (avoids latches)
            o_pm_timeout       <= 1'b0;

            // --- LinkError Timer ---
            if (i_linkerror_timer_start) begin
                if (linkerror_counter >= LINKERROR_TIMEOUT - 1) begin  // Check one cycle early
                    o_linkerror_timeout <= 1'b1;      // Assert timeout
                    linkerror_counter   <= 0;         // Auto-reset
                end else begin
                    linkerror_counter <= linkerror_counter + 1;  // Increment
                end
            end else begin
                linkerror_counter <= 0;  // Clear when not active
                o_linkerror_timeout <= 1'b0;  // Default to not timeout

            end

            // --- PM Timeout Timer ---
            if (i_pm_timer_start) begin
                if (pm_timeout_counter >= PM_TIMEOUT - 1) begin  // Check one cycle early
                    o_pm_timeout     <= 1'b1;      // Assert timeout
                    pm_timeout_counter <= 0;        // Auto-reset
                end else begin
                    pm_timeout_counter <= pm_timeout_counter + 1;  // Increment
                end
            end else begin
                pm_timeout_counter <= 0;  // Clear when not active
            end
        end
    end

endmodule