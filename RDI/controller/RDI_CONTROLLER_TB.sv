module RDI_CONTROLLER_TB ();

/*******************************************
* Clock and Reset
*******************************************/
    bit lclk;
    bit sys_rst;

/*******************************************
* Signals for RDI_CONTROLLER Module
*******************************************/
    // Inputs
    bit [3:0] i_rx_sb_message;
    bit i_rx_msg_valid;
    bit i_reset_only_from_ltsm;
    bit i_pl_error_from_ltsm;
    bit i_pl_inband_pres_from_ltsm;
    bit i_pl_train_error_from_ltsm;
    bit [2:0] i_pl_link_speed_from_ltsm;
    bit [3:0] i_lp_state_req;
    bit i_clk_done;
    bit i_stall_done;
    bit i_bring_up_done;
    bit i_bring_up_pm_entry_done;
    bit i_lp_linkerror;
    bit i_pmnack_from_pm_entry;
    bit i_linkerror_timeout;
    bit i_reset_pin_or_soft_ware_clear_error;


    // Outputs
    bit o_go_to_l1_from_rdi_to_ltsm;
    bit o_go_to_l2_from_rdi_to_ltsm;
    bit o_go_to_active_from_rdi_to_ltsm;
    bit o_go_to_training_from_rdi_to_ltsm;
    bit o_go_to_linkerror_from_rdi_to_ltsm;
    bit o_go_to_retrain_from_rdi_to_ltsm;
    bit [2:0] o_rdi_controller_choosen_bring_up;
    bit [1:0] o_start_pm_entry_bring_up;
    bit [3:0] o_pl_state_sts;
    bit o_start_clk_hand;
    bit o_start_linkerror_timer;
    bit o_exit_from_l1;
    bit o_exit_from_l2;
    bit o_start_stall_hand;
     
    bit i_pm_timer_start;
    bit i_ltsm_is_waked_up; 

/*******************************************
* Signals for General Bring Up Wrapper
*******************************************/
    bit [3:0] o_tx_sb_message;
    bit o_tx_msg_valid;
    bit i_rx_done_send_message;

/*******************************************
* WAke Handshake Signals
*******************************************/
    bit o_clk_gate_en;
    bit i_clk_for_rdi_controller;
    bit o_pl_wake_ack;
    bit i_lp_wake_req; 

/*******************************************
* Stall Handshake Signals
*******************************************/
    bit i_lp_stallack; 
    bit o_pl_stallreq;
    bit o_pl_trdy;    

/*******************************************
* Clock Handshake Signals
*******************************************/
    bit i_lp_clk_ack;
    bit o_pl_clk_req;
////////////// for nop to active test ////////////////////
    bit [1:0] test_nop_To_active_scenarios;
    bit [3:0] i_lp_state_req_delayed;
    bit [3:0] i_lp_state_req_not_actual;

///////////// for nop to linkerror test //////////////
    bit [1:0] test_nop_To_linkerror_scenarios;

////////////// for nop to linkreset test //////////////
    bit [1:0] test_nop_To_linkreset_scenarios;

////////////// for nop to disable test //////////////////
    bit [1:0] test_nop_to_disable_scenarios;

////////////////// FOR RETRAIN SCENARIOES  /////////////////////
    bit [1:0] test_retrain_scenarios;


    parameter active_scenarios = 2'b01;
    parameter for_scenarios_testing=1; 


/*******************************************
* Clock Gating Control Signal
*******************************************/
    assign i_clk_for_rdi_controller =lclk & o_clk_gate_en; // Not used in this testbench

    typedef enum logic [4:0] {
        Nop                                 = 5'b00000, // 0
        Active                              = 5'b00001, // 1
        ACTIVE_HANDLE_FOR_BRING_UP          = 5'b00011, // 3
        ACTIVE_BRING_UP                     = 5'b00101, // 5
        LINKTRAINING                        = 5'b00110, // 6
        BRING_UP                            = 5'b00111, // 7
        PM_BRING_UP                         = 5'b01110, // 14
        CLK_HAND                            = 5'b01101, // 13
        L1                                  = 5'b00100, // 4
        L2                                  = 5'b01000, // 8
        LinkReset                           = 5'b01001, // 9
        LinkError                           = 5'b01010, // 10
        Retrain                             = 5'b01011, // 11
        Disable                             = 5'b01100, // 12
        ActivePMNAK                         = 5'b00010, // 2
        LINKERROR_TIMER                     = 5'b01111, // 15
        STALL_HAND                          = 5'b10000  // 16
    } state_t;

    typedef enum logic [1:0] {
        IDLE_RX             = 2'b00,
        CHECK_REQ_MESSG     = 2'b01,
        RESP_SEND           = 2'b10,
        DONE_RX             = 2'b11
    } state_enum_rx_bring_up;

    typedef enum logic [1:0] {
        IDLE_TX     = 2'b00,
        REQ_SEND    = 2'b01,
        HANDLE      = 2'b10,
        DONE_TX     = 2'b11
    } state_enum_tx_bring_up;

    typedef enum logic [3:0] {
            ACTIVE_REQ      = 4'd1,
            ACTIVE_RSP      = 4'd2,
            LINKRESET_REQ   = 4'd7,
            LINKRESET_RSP   = 4'd8,
            LINKERROR_REQ   = 4'd9,
            LINKERROR_RSP   = 4'd10,
            RETRAIN_REQ     = 4'd11,
            RETRAIN_RSP     = 4'd12,
            DISABLE_REQ     = 4'd13,
            DISABLE_RSP     = 4'd14
    } message_type_t;


    state_t current_state, next_state;
    state_enum_tx_bring_up current_state_tx_bring_up, next_state_tx_bring_up;
    state_enum_rx_bring_up current_state_rx_bring_up, next_state_rx_bring_up;
    message_type_t message_type_tx_bring_up, message_type_rx_bring_up;
    always @(*) begin 
        current_state = state_t'(uut.CS); // Assuming the DUT has a current_state output
        next_state = state_t'(uut.NS); // Assuming the DUT has a next_state output
        current_state_tx_bring_up = state_enum_tx_bring_up'(general_bring_up_wrapper_inst.tx_inst.CS); // Assuming the DUT has a current_state output
        next_state_tx_bring_up = state_enum_tx_bring_up'(general_bring_up_wrapper_inst.tx_inst.NS); // Assuming the DUT has a next_state output
        current_state_rx_bring_up = state_enum_rx_bring_up'(general_bring_up_wrapper_inst.rx_inst.CS); // Assuming the DUT has a current_state output
        next_state_rx_bring_up = state_enum_rx_bring_up'(general_bring_up_wrapper_inst.rx_inst.NS); // Assuming the DUT has a next_state output
        message_type_tx_bring_up = message_type_t'(general_bring_up_wrapper_inst.o_tx_sb_message); // Assuming the DUT has a message_type output
        message_type_rx_bring_up = message_type_t'(general_bring_up_wrapper_inst.i_rx_sb_message); // Assuming the DUT has a message_type output
    end


/*******************************************
* Instantiate the RDI_CONTROLLER module
*******************************************/
    RDI_CONTROLLER_V2 uut (
        .lclk(i_clk_for_rdi_controller),
        .sys_rst(sys_rst),
        .i_rx_sb_message(i_rx_sb_message),
        .i_rx_msg_valid(i_rx_msg_valid),
        .i_reset_only_from_ltsm(i_reset_only_from_ltsm),
        .i_pl_error_from_ltsm(i_pl_error_from_ltsm),
        .i_pl_inband_pres_from_ltsm(i_pl_inband_pres_from_ltsm),
        .i_pl_train_error_from_ltsm(i_pl_train_error_from_ltsm),
        .i_pl_link_speed_from_ltsm(i_pl_link_speed_from_ltsm),
        .i_lp_state_req(i_lp_state_req),
        .i_clk_done(i_clk_done),
        // .i_walk_done(i_walk_done),
        .i_stall_done(i_stall_done),
        .i_bring_up_done(i_bring_up_done),
        .i_bring_up_pm_entry_done(i_bring_up_pm_entry_done),
        .i_lp_linkerror(i_lp_linkerror),
        .i_pmnack_from_pm_entry(i_pmnack_from_pm_entry),
        .i_linkerror_timeout(i_linkerror_timeout),
        .i_reset_pin_or_soft_ware_clear_error(i_reset_pin_or_soft_ware_clear_error),
        .o_go_to_l1_from_rdi_to_ltsm(o_go_to_l1_from_rdi_to_ltsm),
        .o_go_to_l2_from_rdi_to_ltsm(o_go_to_l2_from_rdi_to_ltsm),
        .o_go_to_active_from_rdi_to_ltsm(o_go_to_active_from_rdi_to_ltsm),
        .o_go_to_training_from_rdi_to_ltsm(o_go_to_training_from_rdi_to_ltsm),
        .o_go_to_linkerror_from_rdi_to_ltsm(o_go_to_linkerror_from_rdi_to_ltsm),
        .o_go_to_retrain_from_rdi_to_ltsm(o_go_to_retrain_from_rdi_to_ltsm),
        .o_rdi_controller_choosen_bring_up(o_rdi_controller_choosen_bring_up),
        .o_start_pm_entry_bring_up(o_start_pm_entry_bring_up),
        .o_pl_state_sts(o_pl_state_sts),
        .o_start_clk_hand(o_start_clk_hand),
        .o_start_stall_hand(o_start_stall_hand),
        .o_start_linkerror_timer(o_start_linkerror_timer),
        .o_exit_from_l1(o_exit_from_l1),
        .o_exit_from_l2(o_exit_from_l2)
    );
/*******************************************
* Instantiate and Connect Supporting Modules
*******************************************/
    // Wake Handshake Module
    wake_handshake wake_handshake_inst (
        .i_clk(lclk),
        .i_rst_n(sys_rst),
        .i_lp_state_req(i_lp_state_req),
        .i_lp_wake_req(i_lp_wake_req), // Connected to PM entry signals
        .i_pl_state_sts(o_pl_state_sts),
        .i_sb_msg_valid(i_rx_msg_valid), // Connected to sideband message valid signal
        .i_ltsm_is_waked_up(i_ltsm_is_waked_up), // Connected to active signal
        .i_ltsm_in_reset(i_reset_only_from_ltsm),
        .o_clk_gate_en(o_clk_gate_en), // Not used in this testbench
        .o_pl_wake_ack(o_pl_wake_ack)  // Not used in this testbench
    );
    // Clock Handshake Module
    clk_handshake clk_handshake_inst (
        .i_clk(i_clk_for_rdi_controller),
        .i_rst_n(sys_rst),
        .i_lp_clk_ack(i_lp_clk_ack), // Connected to active signal
        .i_en(o_start_clk_hand), // Connected to PM entry start
        .o_pl_clk_req(o_pl_clk_req), // Not used in this testbench
        .o_adapter_is_waked_up(i_clk_done) // Connected back to RDI controller
    );
    // General Bring Up Wrapper
    General_Bring_Up_Wrapper general_bring_up_wrapper_inst (
        .lclk(i_clk_for_rdi_controller),
        .sys_rst(sys_rst),
        .i_rdi_controller_choosen_bring_up(o_rdi_controller_choosen_bring_up),
        .i_rx_sb_message(i_rx_sb_message),
        .i_rx_msg_valid(i_rx_msg_valid),
        .i_rx_done_send_message(i_rx_done_send_message), // Connected to training signal
        .i_lp_state_req(i_lp_state_req),
        // .i_lp_linkerror(i_lp_linkerror), 
        .o_tx_sb_message(o_tx_sb_message), // Not used in this testbench
        .o_tx_msg_valid(o_tx_msg_valid),  // Not used in this testbench
        .o_General_Bring_Up_done(i_bring_up_done) // Connected back to RDI controller
    );
    // Stall Handshake Module
    stall_hand_chak stall_hand_chak_inst (
        .lclk(i_clk_for_rdi_controller),
        .sys_rst(sys_rst),
        // .i_pl_State_sts(o_pl_state_sts),
        // .i_lp_state_req(i_lp_state_req),
        // .i_rx_sb_message(i_rx_sb_message),
        // .i_rx_sb_message_valid(i_rx_msg_valid),
        // .i_pl_error(i_pl_error_from_ltsm),
        .i_stall_start(o_start_stall_hand),
        .i_lp_stallack(i_lp_stallack), // Connected to active signal
        .o_pl_stallreq(o_pl_stallreq), // Not used in this testbench
        .o_stall_done(i_stall_done), // Connected back to RDI controller
        .o_pl_trdy(o_pl_trdy)      // Not used in this testbench
    );
    // Timer Controller Module
    rdi_timer_controller rdi_timer_controller_inst (
        .lclk(i_clk_for_rdi_controller),
        .sys_rst(sys_rst),
        .i_pm_timer_start(i_pm_timer_start), // Connected to PM entry start
        .i_linkerror_timer_start(o_start_linkerror_timer), // Connected to training signal
        .o_pm_timeout(), // Connected to PM NACK
        .o_linkerror_timeout(i_linkerror_timeout) // Connected to train error
    );

bit [3:0] i_rx_sb_message_delayed;
bit       i_rx_msg_valid_delayed; 
/*******************************************
* Instantiate Signal Delay Modules
*******************************************/
    signal_delay #(
        .DELAY_CYCLES(4),
        .SIGNAL_WIDTH(1)
    ) signal_delay_inst1 (
        .clk(lclk),
        .rst_n(sys_rst),
        .in_signal(o_tx_msg_valid),
        .out_signal(i_rx_done_send_message)
    );
    signal_delay #(
        .DELAY_CYCLES(8),
        .SIGNAL_WIDTH(4)
    ) signal_delay_inst2 (
        .clk(lclk),
        .rst_n(sys_rst),
        .in_signal(o_tx_sb_message),
        .out_signal(i_rx_sb_message_delayed)
    );
    signal_delay #(
        .DELAY_CYCLES(8),
        .SIGNAL_WIDTH(1)
    ) signal_delay_inst3 (
        .clk(lclk),
        .rst_n(sys_rst),
        .in_signal(o_tx_msg_valid),
        .out_signal(i_rx_msg_valid_delayed)
    );


    bit i_lp_wake_req_delayed2;
    signal_delay #(
            .DELAY_CYCLES(3),
            .SIGNAL_WIDTH(1)
        ) signal_delay_inst5 (
            .clk(lclk),
            .rst_n(sys_rst),
            .in_signal(o_clk_gate_en),
            .out_signal(i_ltsm_is_waked_up)
    );
    signal_delay #(
                .DELAY_CYCLES(4),
                .SIGNAL_WIDTH(1)
            ) signal_delay_inst6 (
                .clk(lclk),
                .rst_n(sys_rst),
                .in_signal(o_start_clk_hand),
                .out_signal(i_lp_clk_ack)
    );

    signal_delay #(
                .DELAY_CYCLES(4),
                .SIGNAL_WIDTH(1)
            ) signal_delay_inst8 (
                .clk(lclk),
                .rst_n(sys_rst),
                .in_signal(o_pl_stallreq),
                .out_signal(i_lp_stallack)
    );



//////////////////// for the test _nop_to_active  ////////////////
    bit delayed_lp_state_req;
    // Conditional instantiation and always blocks based on test_nop_To_active_scenarios
    generate
        if (active_scenarios == 1) begin
            // Instantiate signal_delay when test_nop_To_active_scenarios is 1
            signal_delay #(
                .DELAY_CYCLES(15),
                .SIGNAL_WIDTH(1)
            ) signal_delay_inst6 (
                .clk(lclk),
                .rst_n(sys_rst),
                .in_signal(o_go_to_training_from_rdi_to_ltsm),
                .out_signal(i_pl_inband_pres_from_ltsm_delayed)
            );
            // Always block for case when test_nop_To_active_scenarios is 1
            always @(posedge i_pl_inband_pres_from_ltsm_delayed or negedge sys_rst) begin
                if (~ sys_rst) begin 
                i_pl_inband_pres_from_ltsm = 1'b0;
                end else
                i_pl_inband_pres_from_ltsm = 1'b1;
            end
            always @(posedge o_go_to_active_from_rdi_to_ltsm) begin
                i_pl_inband_pres_from_ltsm = 1'b0;
            end
        end
        else if (active_scenarios == 2) begin
            // Always block for case when test_nop_To_active_scenarios is 
        ////// only for acctive
            signal_delay #(
                .DELAY_CYCLES(4),
                .SIGNAL_WIDTH(1)
            ) signal_delay_inst7 (
                .clk(lclk),
                .rst_n(sys_rst),
                .in_signal(i_clk_done),
                .out_signal(delayed_lp_state_req)
            );
            always @(posedge o_go_to_active_from_rdi_to_ltsm) begin
                i_pl_inband_pres_from_ltsm = 1'b0;
            end
            always @(posedge delayed_lp_state_req or negedge sys_rst) begin
                if (~ sys_rst) begin
                    i_lp_state_req_delayed = 4'b0000;
                end else begin
                    i_lp_state_req_delayed = 4'b0001;
                end
            end
        end 
        
    endgenerate
//////////////////// for the test _nop_to_linkerror_scenarios ////////////////

    always @(posedge i_linkerror_timeout or negedge sys_rst) begin
        if (~ sys_rst) begin
            i_reset_pin_or_soft_ware_clear_error = 0;
        end else begin
            i_reset_pin_or_soft_ware_clear_error = 1; // LinkError state request
        end
    end

//////////////////////// for the test nop_to_linkreset //////////////////////////


/*******************************************
* Clock Generation
*******************************************/
    initial begin
        lclk = 0;
        forever #5 lclk = ~lclk;
    end

/*******************************************
* Tasks for Test Scenarios
*******************************************/
    // Task to reset the system
    task reset_system();
        begin
            sys_rst = 0;
            #20 sys_rst = 1;
        end
    endtask

    bit i_lp_wake_req_active;
    bit i_lp_wake_req_linkerror;
    bit i_lp_wake_req_linkreset;
    bit i_lp_wake_req_disable;
    bit [3:0] i_lp_state_req_linkreset;
    bit [3:0] i_lp_state_req_disable;
    bit [3:0] i_lp_state_req_retrain;
    bit i_reset_only_from_ltsm_active;
    bit i_reset_only_from_ltsm_linkreset;
    bit i_reset_only_from_ltsm_disable;


    bit [3:0]  i_rx_sb_message_linkerror;
    bit        i_rx_msg_valid_linkerror;
    bit [3:0]  i_rx_sb_message_linkreset;
    bit        i_rx_msg_valid_linkreset;
    bit [3:0]  i_rx_sb_message_disable ; 
    bit        i_rx_msg_valid_disable;

    bit [3:0]  i_rx_sb_message_retrain;
    bit        i_rx_msg_valid_retrain ;

    always @(*) begin
        if (~sys_rst) begin 
            i_lp_wake_req =0;
            i_lp_state_req =0;
            i_reset_only_from_ltsm=0;
        end else begin
            i_lp_wake_req = (test_nop_To_active_scenarios) ? i_lp_wake_req_active :
                            (test_nop_To_linkerror_scenarios) ? i_lp_wake_req_linkerror :
                            (test_nop_To_linkreset_scenarios) ? i_lp_wake_req_linkreset :
                            (test_nop_to_disable_scenarios)?i_lp_wake_req_disable: 0; // Connect the delayed signal to the actual state request

            i_lp_state_req = (test_nop_To_active_scenarios == 1 && test_nop_To_linkerror_scenarios == 0) ? i_lp_state_req_not_actual :
                            (test_nop_To_active_scenarios == 2 && test_nop_To_linkerror_scenarios == 0) ? i_lp_state_req_delayed :
                            (test_nop_To_linkreset_scenarios == 1) ? i_lp_state_req_linkreset :
                            (test_nop_to_disable_scenarios==1)?i_lp_state_req_disable:(test_retrain_scenarios==1)?i_lp_state_req_retrain: 0; // Connect the delayed signal to the actual state request

            i_reset_only_from_ltsm = (test_nop_To_active_scenarios && test_nop_To_linkerror_scenarios == 0) ? i_reset_only_from_ltsm_active :
                            (test_nop_To_linkreset_scenarios == 2) ? i_reset_only_from_ltsm_linkreset :
                            (test_nop_to_disable_scenarios == 2)?i_reset_only_from_ltsm_disable: 0; // Connect the delayed signal to the actual state request
            // @(posedge i_stall_done) i_reset_only_from_ltsm=0;
        end

    end

    assign i_rx_sb_message = (test_nop_To_linkerror_scenarios == 3 && i_rx_msg_valid_linkerror )?
                             i_rx_sb_message_linkerror :(test_nop_To_linkreset_scenarios == 2 && i_rx_msg_valid_linkreset)?
                             i_rx_sb_message_linkreset: (test_nop_to_disable_scenarios &&i_rx_msg_valid_disable )?
                             i_rx_sb_message_disable:(test_retrain_scenarios &&i_rx_msg_valid_retrain )?
                             i_rx_sb_message_retrain:i_rx_sb_message_delayed; // Assign based on scenario
    assign i_rx_msg_valid = (test_nop_To_linkerror_scenarios == 3 && i_rx_sb_message_linkerror )?
                             i_rx_msg_valid_linkerror :(test_nop_To_linkreset_scenarios == 2  && i_rx_sb_message_linkreset)?
                             i_rx_msg_valid_linkreset :(test_nop_to_disable_scenarios &&i_rx_sb_message_disable )?
                             i_rx_msg_valid_disable:(test_retrain_scenarios &&i_rx_sb_message_retrain )?
                             i_rx_msg_valid_retrain: i_rx_msg_valid_delayed; // Assign based on scenario

//////////////////////// for the test nop to active scenarios ///////////////////////////////
// Task to test transition from Nop to Active, with scenario selection
    task test_nop_to_active(input bit [1:0] test_nop_To_active_scenarios);
        begin
            $display("=== Testing NOP to ACTIVE Transition - Scenario %0d ===", test_nop_To_active_scenarios);
            repeat(2) @(posedge lclk);
            case (test_nop_To_active_scenarios)
                2'b01: begin
                    $display("-> Scenario 1: Normal wake request then state request");
                    i_lp_wake_req_active = 1;
                    i_reset_only_from_ltsm_active=1;
                    repeat (10) @(posedge lclk);
                    i_lp_state_req_not_actual = 4'b0001; // Active
                end
                2'b10: begin
                    $display("-> Scenario 2: Wake request delayed before state request");
                    i_reset_only_from_ltsm_active=0;
                    i_pl_inband_pres_from_ltsm = 1;
                end
                default: begin
                    $display("-> Unknown scenario. No action taken.");
                end
            endcase
        end
    endtask
////////////////////// for the test _nop_to_linkerror_scenarios ////////////////
    // Task to test transition to LinkError
    bit i_pl_train_error_from_ltsm_linkerror,i_lp_linkerror_linkerror;
    assign i_pl_train_error_from_ltsm = (test_nop_To_linkerror_scenarios ==2)? i_pl_train_error_from_ltsm_linkerror:0;
    assign i_lp_linkerror =(test_nop_To_linkerror_scenarios ==1 )?i_lp_linkerror_linkerror:0;
    task test_link_error(input bit [1:0] test_nop_To_linkerror_scenarios);
        begin
            $display("=== Testing NOP to LINKERROR Transition - Scenario %0d ===", test_nop_To_linkerror_scenarios);
            if (test_nop_To_linkerror_scenarios == 1)begin
                i_lp_wake_req_linkerror = 1;
                repeat (10) @(posedge lclk);
                i_lp_linkerror_linkerror = 1;
                i_pl_train_error_from_ltsm_linkerror=0;
                i_rx_sb_message_linkerror = 4'd0; // LinkError Request
                i_rx_msg_valid_linkerror = 1'b0;
                #20;                
            end else if (test_nop_To_linkerror_scenarios == 2) begin
                i_pl_train_error_from_ltsm_linkerror = 1;
                i_lp_linkerror_linkerror = 0;
                i_rx_sb_message_linkerror = 4'd0; // LinkError Request
                i_rx_msg_valid_linkerror = 1'b0;
                #20;
            end else if (test_nop_To_linkerror_scenarios == 3) begin
                i_pl_train_error_from_ltsm_linkerror = 0;
                i_lp_linkerror_linkerror = 0;
                i_rx_sb_message_linkerror = 4'd9; // LinkError Request
                i_rx_msg_valid_linkerror = 1'b1;
                #40;
                i_rx_sb_message_linkerror = 4'd0; // LinkError Request
                i_rx_msg_valid_linkerror = 1'b0;
            end else begin
                $display("-> Unknown scenario. No action taken.");
            end

        end
    endtask
/////////////////////////////// for the test nop_to_linkreset_scenarios ////////////////////////////

    // Task to test transition to Linkreset
    task test_link_reset(input bit [1:0] test_nop_To_linkreset_scenarios);
        begin
            $display("=== Testing NOP to LINKERESET Transition - Scenario %0d ===", test_nop_To_linkreset_scenarios);
            if (test_nop_To_linkreset_scenarios == 1)begin
                if (uut.CS==Nop) begin
                    i_lp_wake_req_linkreset = 1;
                    repeat (10) @(posedge lclk);
                    i_lp_state_req_linkreset = 4'b1001; // LinkReset state request
                end else begin
                    i_lp_state_req_linkreset = 4'b1001; // LinkReset state request   
                end
                i_rx_sb_message_linkreset = 4'd0; // LinkError Request
                i_rx_msg_valid_linkreset = 1'b0;
                #20;                
            end else if (test_nop_To_linkreset_scenarios == 2) begin
                i_lp_state_req_linkreset = 0; // LinkReset state request
                i_reset_only_from_ltsm_linkreset=1;
                i_rx_sb_message_linkreset = 7; // Linkreset Request
                i_rx_msg_valid_linkreset = 1'b1;
                #40;
                i_rx_sb_message_linkreset = 4'd0; // LinkError Request
                i_rx_msg_valid_linkreset = 1'b0;
            end else begin
                $display("-> Unknown scenario. No action taken.");
            end
        end
    endtask

/////////////////////////////// for the test nop_to_Disable_scenarios ////////////////////////////
    // Task to test transition to Linkreset
    task test_disable(input bit [1:0] test_nop_to_disable_scenarios);
        begin
            $display("=== Testing NOP to LINKERESET Transition - Scenario %0d ===", test_nop_to_disable_scenarios);
            if (test_nop_to_disable_scenarios == 1)begin
                if (uut.CS==Nop) begin
                    i_lp_wake_req_disable = 1;
                    repeat (10) @(posedge lclk);
                    i_lp_state_req_disable = 4'b1100; // Disable 
                end else begin
                    i_lp_state_req_disable = 4'b1100; // Disable 
                end                
                i_rx_sb_message_disable = 4'd0; // LinkError Request
                i_rx_msg_valid_disable = 1'b0;
                #20;                
            end else if (test_nop_to_disable_scenarios == 2) begin
                i_lp_state_req_disable = 0; // LinkReset state request
                i_reset_only_from_ltsm_disable=1;
                i_rx_sb_message_disable = 13; // Linkreset Request
                i_rx_msg_valid_disable = 1'b1;
                #40;
                i_rx_sb_message_disable = 4'd0; // LinkError Request
                i_rx_msg_valid_disable = 1'b0;
            end else begin
                $display("-> Unknown scenario. No action taken.");
            end
        end
    endtask
bit i_pl_error_from_ltsm_retrain;
assign i_pl_error_from_ltsm = (test_retrain_scenarios==3)?i_pl_error_from_ltsm_retrain:0;
////////////////////////////////////////////// TASK RETRAIN /////////////////////////////////////////////////////
    task test_retrain(input bit [1:0] test_retrain_scenarios);
        begin
            $display("=== Testing NOP to LINKERESET Transition - Scenario %0d ===", test_retrain_scenarios);
            if (test_retrain_scenarios == 1)begin
                i_lp_state_req_retrain = 4'b1011; // Disable           
                i_rx_sb_message_retrain = 4'd0; // LinkError Request
                i_rx_msg_valid_retrain = 1'b0;
                i_pl_error_from_ltsm_retrain=0;
                #20;                
            end else if (test_retrain_scenarios == 2) begin
                i_lp_state_req_retrain = 0; // LinkReset state request
                i_rx_sb_message_retrain = 11; // LinkError Request
                i_rx_msg_valid_retrain = 1'b1;
                #40;
                i_rx_sb_message_retrain = 4'd0; // LinkError Request
                i_rx_msg_valid_retrain = 1'b0;
                i_pl_error_from_ltsm_retrain=0;
                #20;      
            end else if (test_retrain_scenarios == 3) begin
                i_pl_error_from_ltsm_retrain=1;
                i_lp_state_req_retrain=0;
                i_rx_sb_message_retrain = 4'd0; // LinkError Request
                i_rx_msg_valid_retrain = 1'b0;
                #20;      
            end
        end
    endtask



/*******************************************
* Test Stimulus
*******************************************/
    initial begin

///////////////////////////////////////////////////////////// NOP ///////////////////////////////////////////////////
        // Run test scenarios
        reset_system();
        #10;
        ////////// for nop to active test ////////////
        if (for_scenarios_testing == 1 ||for_scenarios_testing == 3 ||for_scenarios_testing == 5) begin
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
        end else if (for_scenarios_testing ==2 ||for_scenarios_testing == 4 || for_scenarios_testing == 6)begin 
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
        end
        test_nop_to_active(test_nop_To_active_scenarios);
        # 1000;

////////////// for nop to linkerror test ////////////
        reset_system();
        #10;
        test_nop_To_active_scenarios = 2'b00; // Scenario 1
        test_nop_To_linkerror_scenarios = 1; // Scenario 1
        test_link_error(test_nop_To_linkerror_scenarios);
        # 16300;
        // seconed test for nop to linkerror
        reset_system();
        #10;
        test_nop_To_linkerror_scenarios = 2; // Scenario 1
        test_link_error(test_nop_To_linkerror_scenarios);
        # 16300;
        // third test for nop to linkerror
        reset_system();
        #10;
        test_nop_To_linkerror_scenarios = 3; // Scenario 1
        test_link_error(test_nop_To_linkerror_scenarios);
        # 16300;
        
////////////// for nop to linkreset test ////////////
        reset_system();
        #10;
        test_nop_To_linkerror_scenarios =0;
        test_nop_To_linkreset_scenarios = 1; // Scenario 1
        test_link_reset(test_nop_To_linkreset_scenarios);
        # 350;
        // seconed test for nop to linkreset
        reset_system();
        test_nop_To_linkreset_scenarios = 2; // Scenario 1
        test_link_reset(test_nop_To_linkreset_scenarios);
        # 350;

        ////////////// for nop to disable test ////////////
        reset_system();
        test_nop_To_linkreset_scenarios = 0; // Scenario 1
        test_nop_to_disable_scenarios=1;
        test_disable(test_nop_to_disable_scenarios);
        # 350;
        // seconed
        reset_system();
        test_nop_to_disable_scenarios = 2; // Scenario 2
        test_disable(test_nop_to_disable_scenarios);
        # 350;
        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
///////////////////////////////////////////////////////////// NOP ----> ACTIVE ----> .... ///////////////////////////////////////////////////
////////////// for nop ----> active (1) ------> linkreset test(1)  ////////////
        if (for_scenarios_testing == 1)  begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_to_disable_scenarios= 0;
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> linkreset test(1) ////////////
        end else if (for_scenarios_testing==2)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_linkreset_scenarios=0;
            test_nop_to_disable_scenarios= 0;
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #1000;
////////////// for nop ----> active(1) ------> linkreset test(2) ////////////
        end else if (for_scenarios_testing==3)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_linkreset_scenarios=0;
            test_nop_to_disable_scenarios=0;
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> linkreset test(2) ////////////
            
        end else if (for_scenarios_testing==4)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_linkreset_scenarios=0;
            test_nop_to_disable_scenarios=0;
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #1000;            
        end

        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
////////////// for nop ----> active (1) ------> disable test(1)  ////////////
        if (for_scenarios_testing == 1)  begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to disable using 1 scenario /////
            test_nop_to_disable_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_disable(test_nop_to_disable_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> disable test(1) ////////////
        end else if (for_scenarios_testing==2)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to disable using 1 scenario /////
            test_nop_to_disable_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_disable(test_nop_to_disable_scenarios);
            #1000;
////////////// for nop ----> active(1) ------> disable test(2) ////////////
        end else if (for_scenarios_testing==3)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to disable using 1 scenario /////
            test_nop_to_disable_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_disable(test_nop_to_disable_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> disable test(2) ////////////
            
        end else if (for_scenarios_testing==4)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to disable using 1 scenario /////
            test_nop_to_disable_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_disable(test_nop_to_disable_scenarios);
            #1000;            
        end

        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
        test_retrain_scenarios =0;
////////////// for nop ----> active (1) ------> retrain test(1)  ////////////
        if (for_scenarios_testing == 1)  begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> retrain test(1) ////////////
        end else if (for_scenarios_testing==2)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;
////////////// for nop ----> active(1) ------> retrain test(2) ////////////
        end else if (for_scenarios_testing==3)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> retrain test(2) ////////////
        end else if (for_scenarios_testing==4)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;    
////////////// for nop ----> active(1) ------> retrain test(3) ////////////        
        end else if (for_scenarios_testing==5)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 3; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;
////////////// for nop ----> active(2) ------> retrain test(3) ////////////        
            
        end else if (for_scenarios_testing==6)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 3; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;            
        end
        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
        test_retrain_scenarios =0;
////////////// for nop ----> active (1) ------> Linkerror test(1)  ////////////
        if (for_scenarios_testing == 1)  begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_nop_To_linkerror_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16800;
////////////// for nop ----> active(2) ------> linkerror test(1) ////////////
        end else if (for_scenarios_testing==2)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkerror using 1 scenario /////
            test_nop_To_linkerror_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16900;
////////////// for nop ----> active(1) ------> linkerror test(2) ////////////
        end else if (for_scenarios_testing==3)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkerror using 1 scenario /////
            test_nop_To_linkerror_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16900;
////////////// for nop ----> active(2) ------> linkerror test(2) ////////////
        end else if (for_scenarios_testing==4)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkerror using 1 scenario /////
            test_nop_To_linkerror_scenarios = 2; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16900;    
////////////// for nop ----> active(1) ------> linkerror test(3) ////////////        
        end else if (for_scenarios_testing==5)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkerror using 1 scenario /////
            test_nop_To_linkerror_scenarios = 3; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16900;
////////////// for nop ----> active(2) ------> linkerror test(3) ////////////        
            
        end else if (for_scenarios_testing==6)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkerror using 1 scenario /////
            test_nop_To_linkerror_scenarios = 3; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_link_error(test_nop_To_linkerror_scenarios);
            #16900;            
        end

///////////////////////////////////////////////////////////// NOP ----> ACTIVE ----> LINKRESET ----> ACTIVE (NOP) .... ///////////////////////////////////////////////////
        $display(" NOP ----> ACTIVE ----> LINKRESET ----> ACTIVE (NOP)");    
        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
        test_retrain_scenarios =0;
        if (for_scenarios_testing ==1 ) begin 
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 600;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #600;
            test_nop_To_linkreset_scenarios =0;
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 600;
        end

///////////////////////////////////////////////////////////// NOP ----> ACTIVE ----> LINKRESET ----> DISAABLE  .... ///////////////////////////////////////////////////
        $display(" NOP ----> ACTIVE ----> LINKRESET ----> ACTIVE (NOP)");    
        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
        test_retrain_scenarios =0;
        if (for_scenarios_testing ==1 ) begin 
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 600;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #600;
            test_nop_To_linkreset_scenarios =0;
            test_nop_to_disable_scenarios = 2'b01; // Scenario 1
            test_disable(test_nop_to_disable_scenarios);
            # 600;
        end else if (for_scenarios_testing==2)begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_linkreset_scenarios=0;
            test_nop_to_disable_scenarios= 0;
            test_nop_To_active_scenarios = 2'b10; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to linkreset using 1 scenario /////
            test_nop_To_linkreset_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios  =0;
            test_link_reset(test_nop_To_linkreset_scenarios);
            #1000;
            test_nop_To_linkreset_scenarios =0;
            test_nop_to_disable_scenarios = 2'b10; // Scenario 1
            test_disable(test_nop_to_disable_scenarios);
            # 600;
        end

///////////////////////////////////////////////////////////// NOP ----> ACTIVE ----> RETRAIN ----> DISAABLE  .... ///////////////////////////////////////////////////
        $display("NOP ----> ACTIVE ----> RETRAIN ----> DISAABLE ");
        test_nop_To_active_scenarios=0;
        test_nop_to_disable_scenarios=0;
        test_nop_To_linkreset_scenarios=0;
        test_nop_To_linkerror_scenarios=0;
        test_retrain_scenarios =0;
        if (for_scenarios_testing == 1)  begin
            reset_system();
            #10;
            ////////// for nop to active test ////////////
            test_nop_To_active_scenarios = 2'b01; // Scenario 1
            test_nop_to_active(test_nop_To_active_scenarios);
            # 1000;
            ////// then from active to retrain using 1 scenario /////
            test_retrain_scenarios = 1; // Scenario 1
            test_nop_To_active_scenarios=0;
            test_retrain(test_retrain_scenarios);
            #1000;
            test_retrain_scenarios=0;
            test_nop_to_disable_scenarios = 2'b01; // Scenario 1
            test_disable(test_nop_to_disable_scenarios);
            # 600;
        end
        // End simulation
        $stop;
    end
endmodule