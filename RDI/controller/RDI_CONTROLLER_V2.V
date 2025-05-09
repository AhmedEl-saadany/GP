module RDI_CONTROLLER_V2 (
    input               lclk,
    input               sys_rst,
    input   [3:0]       i_rx_sb_message,
    input               i_rx_msg_valid, // sb_message_valid from rx_b
    input               i_reset_only_from_ltsm, // reset only from ltsm
    input               i_pl_error_from_ltsm, // Message type (Request/Response) (valid fram error in ltsm) // retrain
    input               i_pl_inband_pres_from_ltsm, // inband presence signal from ltsm to indicate it is in the linkinitialization state
    input               i_pl_train_error_from_ltsm, // train error signal from ltsm to indicate linkerror state
    input  [2:0]        i_pl_link_speed_from_ltsm, // link speed signal from ltsm to indicate the link speed
    // input               i_pl_link_speed_from_ltsm_to_syncronizer, 
    input  [3:0]        i_lp_state_req,
    input               i_clk_done,
    // input               i_walk_done,
    input               i_stall_done,
    input               i_bring_up_done,
    input               i_bring_up_pm_entry_done,
    input               i_lp_linkerror,
    input               i_pmnack_from_pm_entry, // pm_nack signal from pm entry to rdi controller
    input               i_linkerror_timeout,
    input               i_reset_pin_or_soft_ware_clear_error , // for reset 
    output reg          o_go_to_l1_from_rdi_to_ltsm, // go to l1 signal from rdi controller to ltsm
    output reg          o_go_to_l2_from_rdi_to_ltsm, // go to l2 signal from rdi controller to ltsm
    output reg          o_go_to_active_from_rdi_to_ltsm, // go to active signal from rdi controller to ltsm
    output reg          o_go_to_training_from_rdi_to_ltsm,
    output reg          o_go_to_linkerror_from_rdi_to_ltsm,
    output reg          o_go_to_retrain_from_rdi_to_ltsm,
    output reg [2:0]    o_rdi_controller_choosen_bring_up, // This are 3 bits (level signal) used to choose which bring will use in the bring up block (1 ACTIVE ,2 RETRAIN, 3 LINKERROR ,4 LINKRESET, 5 DISABLE)
    output reg [1:0]    o_start_pm_entry_bring_up, // start pm entry signal from rdi controller to ltsm
    output reg [3:0]    o_pl_state_sts,
    output reg          o_start_clk_hand,
    output reg          o_start_stall_hand,
    // output reg          o_clock_gating,
    output reg          o_start_linkerror_timer,
    output reg          o_exit_from_l1,
    output reg          o_exit_from_l2
);

    // State definitions as local parameters
    localparam [4:0] 
        Nop                                 = 5'b00000, // 0
        Active                              = 5'b00001, // 1
        // ACTIVE_HANDLE_FOR_LINK_TRAINING     = 5'b01110, // 14
        ACTIVE_HANDLE_FOR_BRING_UP          = 5'b00011, // 3
        ACTIVE_BRING_UP                     = 5'b00101, // 5
        LINKTRAINING                        = 5'b00110, // 6
        BRING_UP                            = 5'b00111, // 7
        PM_BRING_UP                         = 5'b01110, // 16 NEW 14
        CLK_HAND                            = 5'b01101, // 13
        L1                                  = 5'b00100, // 5
        L2                                  = 5'b01000, // 8
        LinkReset                           = 5'b01001, // 9
        LinkError                           = 5'b01010, // 10
        Retrain                             = 5'b01011, // 11
        Disable                             = 5'b01100, // 12
        ActivePMNAK                         = 5'b00010, // 2
        LINKERROR_TIMER                     = 5'b01111, //15
        STALL_HAND                          = 5'b10000; //16

    // Message encodings as local parameters
    localparam [3:0] 
        ACTIVE_REQ      = 4'd0001,
        ACTIVE_RSP      = 4'd2,
        L1_REQ          = 4'd3,
        L1_RSP          = 4'd4,
        L2_REQ          = 4'd5,
        L2_RSP          = 4'd6,
        LINKRESET_REQ   = 4'd7,
        LINKRESET_RSP   = 4'd8,
        LINKERROR_REQ   = 4'd9,
        LINKERROR_RSP   = 4'd10,
        RETRAIN_REQ     = 4'd11,
        RETRAIN_RSP     = 4'd12,
        DISABLE_REQ     = 4'd13,
        DISABLE_RSP     = 4'd14,
        PM_NAK_MSG      = 4'd15;

        // internal signals

        reg registered_LINKERROR_REQ,
            registered_LINKRESET_REQ,
            registered_DISABLE_REQ,
            registered_RETRAIN_REQ,
            registered_ACTIVE_REQ,
            registered_L1_REQ,
            registered_L2_REQ,
            exit_from_l1,
            exit_from_l2;

        wire stall_start,condition_1,condition_2,condition_3,condition_4; // Stall start signal from external logic; // conditon 1 transition to retrain // condiotion 2 transion to pm // transition 3 tolinkreset // transition 4 to disable
        reg [4:0] CS, NS;
    // Example conditions for stall start
    assign condition_1 = (CS == Active) &&(((i_rx_sb_message == RETRAIN_REQ) && i_rx_msg_valid)||i_lp_state_req==Retrain ||i_pl_error_from_ltsm ); // Example condition 1
    assign condition_2 = (CS == Active) &&((i_lp_state_req == L1 || i_lp_state_req == L2) || ((i_rx_sb_message == L1_REQ) && i_rx_msg_valid) || ((i_rx_sb_message == L2_REQ) && i_rx_msg_valid));
    assign condition_3 = (CS == Active) && (((i_rx_sb_message == LINKRESET_REQ) && i_rx_msg_valid) || i_lp_state_req==LinkReset); // Example condition 3
    assign condition_4 = (CS == Active) && (((i_rx_sb_message == DISABLE_REQ) && i_rx_msg_valid) || i_lp_state_req==Disable); // Example condition 4   

    assign stall_start = condition_1 | condition_2 | condition_3 | condition_4; // Example conditions for stall start    
        
        always @(posedge lclk or negedge sys_rst) begin
            if (!sys_rst) begin
               registered_LINKERROR_REQ<=0;
               registered_LINKRESET_REQ <=0; 
               registered_DISABLE_REQ <=0;
               registered_RETRAIN_REQ <=0;
                registered_L1_REQ <=0;
                registered_L2_REQ <=0;
                exit_from_l1 <=0;
                exit_from_l2<=0;
                registered_ACTIVE_REQ<=0;
            end else begin
                if (CS == LinkError) registered_LINKERROR_REQ <=0; 
                else if (CS == LinkReset) registered_LINKRESET_REQ <=0;
                else if (CS == Disable) registered_DISABLE_REQ <=0;
                else if (CS == Retrain) registered_RETRAIN_REQ <=0;
                else if (CS == L1 ) registered_L1_REQ<=0;
                else if (CS == L2) registered_L2_REQ<=0;
                else if (CS == BRING_UP) registered_ACTIVE_REQ<=0;
                else if (CS == L1 && NS ==BRING_UP) exit_from_l1<=1;
                else if (CS == L2 && NS ==BRING_UP) exit_from_l2<=1;
                else begin
                    if (i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid) registered_LINKERROR_REQ<=1;
                    else if (i_rx_sb_message == LINKRESET_REQ && i_rx_msg_valid) registered_LINKRESET_REQ <=1;
                    else if ((i_rx_sb_message == DISABLE_REQ && i_rx_msg_valid)) registered_DISABLE_REQ <=1;
                    else if ((i_rx_sb_message == RETRAIN_REQ) && i_rx_msg_valid) registered_RETRAIN_REQ <=1;
                    else if ((i_rx_sb_message == L1_REQ) && i_rx_msg_valid) registered_L1_REQ <=1;
                    else if ((i_rx_sb_message == L2_REQ) && i_rx_msg_valid) registered_L2_REQ <=1;        
                    else if ((i_rx_sb_message == ACTIVE_REQ) && i_rx_msg_valid) registered_ACTIVE_REQ <=1;            
                end
            end
        end
        always @(posedge lclk or negedge sys_rst) begin
            if (!sys_rst)
                CS <= Nop;
            else
                CS <= NS;
        end

     // Next state logic
        always @(*) begin
            NS = CS; // Default to current state
            case (CS)
                Nop: begin
                    // if (i_walk_done) NS =ACTIVE_HANDLE_FOR_LINK_TRAINING;
                    if (i_lp_state_req ==Active) NS = LINKTRAINING;
                    else if (i_pl_inband_pres_from_ltsm) NS= CLK_HAND;
                    else if (i_lp_linkerror) NS =BRING_UP;
                    else if (i_pl_train_error_from_ltsm || (i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid)) NS = CLK_HAND;
                    else if (i_reset_only_from_ltsm && ((i_rx_sb_message == LINKRESET_REQ && i_rx_msg_valid)|| (i_rx_sb_message == DISABLE_REQ && i_rx_msg_valid))) NS =CLK_HAND;
                    else if ((i_lp_state_req == LinkReset)) NS = BRING_UP;
                    else if ((i_lp_state_req == Disable)) NS = BRING_UP;
                end
                CLK_HAND: begin 
                    if (i_clk_done && i_pl_inband_pres_from_ltsm) NS = ACTIVE_HANDLE_FOR_BRING_UP;
                    else if (i_clk_done && (i_pl_train_error_from_ltsm || registered_LINKERROR_REQ || registered_ACTIVE_REQ)) NS = BRING_UP;
                    else if (i_clk_done && (registered_LINKRESET_REQ || registered_DISABLE_REQ ||registered_LINKERROR_REQ )) NS =BRING_UP;
                end
                // ACTIVE_HANDLE_FOR_LINK_TRAINING : begin
                //     if (i_lp_state_req ==Active) NS = LINKTRAINING;
                // end
                ACTIVE_HANDLE_FOR_BRING_UP : begin
                    if (i_lp_state_req == Active) NS = BRING_UP;
                end
                LINKTRAINING : begin
                    if (i_pl_inband_pres_from_ltsm) NS = BRING_UP;
                end
                BRING_UP : begin
                    if (i_pl_inband_pres_from_ltsm && i_bring_up_done) NS =Active;
                    else if (i_bring_up_done && (i_lp_linkerror || i_pl_train_error_from_ltsm || registered_LINKERROR_REQ)) NS = LinkError;
                    else if (i_bring_up_done &&(i_lp_state_req == LinkReset ||registered_LINKRESET_REQ)) NS =LinkReset;
                    else if (i_bring_up_done && (i_lp_state_req == Disable || registered_DISABLE_REQ)) NS= Disable;
                    else if (i_bring_up_done && (i_lp_state_req==Retrain ||i_pl_error_from_ltsm|| registered_RETRAIN_REQ)) NS= Retrain;
                    else if (i_bring_up_done && exit_from_l1) NS=Retrain;
                    else if (i_bring_up_done && exit_from_l2) NS=Nop;
                end
                STALL_HAND: begin
                    if (i_stall_done) begin 
                        if (!(registered_L1_REQ||registered_L1_REQ ||o_pl_state_sts == L1 || o_pl_state_sts == L2))
                            NS =BRING_UP;
                        else NS=PM_BRING_UP;
                    end
                    if (i_pmnack_from_pm_entry) NS=ActivePMNAK;
                end
                Active: begin
                    if (stall_start) NS =STALL_HAND;
                    else if (i_lp_linkerror||i_pl_train_error_from_ltsm || (i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid))NS=BRING_UP;
                end
                PM_BRING_UP: begin
                    if (i_bring_up_pm_entry_done)begin
                        if (registered_L1_REQ ||o_pl_state_sts == L1) NS =L1;
                        else NS =L2;
                    end
                end
                LinkError :begin
                    NS = LINKERROR_TIMER; 
                end
                LINKERROR_TIMER : begin
                    if (i_linkerror_timeout &&(i_reset_pin_or_soft_ware_clear_error ||(i_lp_state_req == Active && i_lp_linkerror==0 ))) NS=Nop;
                end
                LinkReset : begin
                    if (i_reset_pin_or_soft_ware_clear_error ||i_lp_state_req == Active) NS=Nop;
                    else if (i_lp_linkerror ||i_lp_state_req == Disable ) NS=BRING_UP;
                    else if ((i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid) || (i_rx_sb_message == DISABLE_REQ && i_rx_msg_valid)) NS= CLK_HAND;
                end
                Disable : begin
                    if (i_reset_pin_or_soft_ware_clear_error ||i_lp_state_req == Active) NS=Nop;
                    else if (i_lp_linkerror ) NS=BRING_UP;
                    else if (i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid) NS= CLK_HAND;
                end
                L1 : begin
                    // if (i_walk_done) NS = ACTIVE_HANDLE_FOR_BRING_UP;
                    if (i_lp_state_req == Active) NS = BRING_UP;
                    else if (((i_rx_sb_message == ACTIVE_REQ) && i_rx_msg_valid)) NS= CLK_HAND;
                end
                L2: begin
                    // if (i_walk_done) NS = ACTIVE_HANDLE_FOR_BRING_UP;
                    if (i_lp_state_req == Active) NS = BRING_UP;
                    else if (((i_rx_sb_message == ACTIVE_REQ) && i_rx_msg_valid)) NS= CLK_HAND;
                end
                ActivePMNAK: begin
                    if (i_lp_state_req == Active) NS= Active;
                end
                Retrain: begin
                    if (exit_from_l1) begin
                        if (i_pl_inband_pres_from_ltsm) 
                            NS = BRING_UP;
                    end else if (
                        (i_lp_state_req == Disable || (i_rx_sb_message == DISABLE_REQ && i_rx_msg_valid)) ||
                        (i_lp_state_req == LinkReset || (i_rx_sb_message == LINKRESET_REQ && i_rx_msg_valid)) ||
                        (i_lp_linkerror || i_pl_train_error_from_ltsm || (i_rx_sb_message == LINKERROR_REQ && i_rx_msg_valid))
                    ) begin
                        NS = BRING_UP;
                    end else if (i_lp_state_req == Nop) begin
                        NS = Nop;
                    end
                    //  else if (i_lp_state_req == Nop) NS=Nop;
                end

            endcase
        end
    // ouput logic
        always @(posedge lclk or negedge sys_rst) begin
            if (!sys_rst) begin
                o_rdi_controller_choosen_bring_up <= 0;
                o_go_to_training_from_rdi_to_ltsm <= 0;
                o_go_to_active_from_rdi_to_ltsm <=0;
                o_pl_state_sts <= 0;
                o_start_clk_hand <= 0;
                // o_clock_gating <= 0;
                o_go_to_linkerror_from_rdi_to_ltsm <= 0;
                o_start_pm_entry_bring_up <=0;
                o_go_to_l1_from_rdi_to_ltsm <=0;
                o_go_to_l2_from_rdi_to_ltsm <=0;
                o_start_linkerror_timer <=0;
                o_go_to_retrain_from_rdi_to_ltsm<=0;
                o_exit_from_l2<=0;
                o_exit_from_l1<=0;
                o_start_stall_hand<=0;
            end
            else begin
                o_rdi_controller_choosen_bring_up <= 0;
                o_go_to_training_from_rdi_to_ltsm <= 0;
                o_go_to_active_from_rdi_to_ltsm <=0;
                o_pl_state_sts <= 0;
                o_start_clk_hand <= 0;  
                o_go_to_linkerror_from_rdi_to_ltsm <=0;
                // o_clock_gating <= 0;
                o_start_pm_entry_bring_up <=0;
                o_go_to_l1_from_rdi_to_ltsm <=0;
                o_go_to_l2_from_rdi_to_ltsm <=0;
                o_start_linkerror_timer <=0;
                o_go_to_retrain_from_rdi_to_ltsm<=0;
                o_exit_from_l2<=0;
                o_exit_from_l1<=0;
                o_start_stall_hand<=0;
                case (NS) 
                    Nop: begin
                        // if (!i_reset_only_from_ltsm) o_clock_gating <= 1;
                        // else 
                        o_pl_state_sts <= Nop;
                        if (exit_from_l2) begin
                            o_exit_from_l2<=1;
                            exit_from_l2<=0;
                        end
                    end
                    LINKTRAINING:begin
                        o_go_to_training_from_rdi_to_ltsm <=1;
                    end 
                    BRING_UP : begin
                        if      (i_pl_inband_pres_from_ltsm || exit_from_l1 || exit_from_l2) o_rdi_controller_choosen_bring_up <= 3'b001;
                        else if ((i_lp_state_req==Retrain ||i_pl_error_from_ltsm|| registered_RETRAIN_REQ)) o_rdi_controller_choosen_bring_up<= 3'b010;
                        else if (i_lp_linkerror || i_pl_train_error_from_ltsm || registered_LINKERROR_REQ) o_rdi_controller_choosen_bring_up<= 3'b011;
                        else if (i_lp_state_req == LinkReset ||registered_LINKRESET_REQ) o_rdi_controller_choosen_bring_up <= 3'b100;
                        else if (i_lp_state_req == Disable || registered_DISABLE_REQ) o_rdi_controller_choosen_bring_up <= 3'b101;
                    end
                    STALL_HAND: begin
                        o_start_stall_hand<=1;
                    end
                    Active : begin
                        o_pl_state_sts <= Active;
                        o_go_to_active_from_rdi_to_ltsm <=1;
                    end
                    CLK_HAND : begin
                        o_start_clk_hand <=1;
                    end
                    LinkError: begin
                        o_pl_state_sts <= LinkError;
                        if (! i_pl_train_error_from_ltsm) o_go_to_linkerror_from_rdi_to_ltsm <=1;
                    end
                    LinkReset: begin
                        o_pl_state_sts <= LinkReset;
                        // o_clock_gating <= 1;
                    end
                    Disable: begin
                        o_pl_state_sts <= Disable;
                        // o_clock_gating <= 1;
                    end
                    PM_BRING_UP: begin
                        if (registered_L1_REQ ||o_pl_state_sts == L1  ) o_start_pm_entry_bring_up<=1;
                        else  o_start_pm_entry_bring_up<=2;
                    end
                    L1: begin
                        o_pl_state_sts <=L1;
                        // o_clock_gating <= 1; 
                        o_go_to_l1_from_rdi_to_ltsm<=1;        
                    end  
                    L2: begin
                        o_pl_state_sts <=L2;
                        // o_clock_gating <= 1; 
                        o_go_to_l2_from_rdi_to_ltsm<=2;        
                    end
                    LINKERROR_TIMER : begin 
                        o_start_linkerror_timer <=1;
                        o_pl_state_sts <= LinkError;
                        if (! i_pl_train_error_from_ltsm) o_go_to_linkerror_from_rdi_to_ltsm <=1;
                    end  
                    Retrain:begin
                        o_pl_state_sts<=Retrain;
                        if (exit_from_l1) begin
                            o_exit_from_l1<=1;
                        end else o_go_to_retrain_from_rdi_to_ltsm<=1; 
                    end
                    ActivePMNAK: begin
                        o_pl_state_sts <=ActivePMNAK;
                    end
                    default begin
                        o_rdi_controller_choosen_bring_up <= 0;
                        o_go_to_training_from_rdi_to_ltsm <= 0;
                        o_go_to_active_from_rdi_to_ltsm <=0;
                        o_pl_state_sts <= 0;
                        o_start_clk_hand <= 0;  
                        o_go_to_linkerror_from_rdi_to_ltsm <=0;
                        // o_clock_gating <= 0;
                        o_start_pm_entry_bring_up <=0;
                        o_go_to_l1_from_rdi_to_ltsm <=0;
                        o_go_to_l2_from_rdi_to_ltsm <=0;
                        o_start_linkerror_timer <=0;
                        o_go_to_retrain_from_rdi_to_ltsm<=0;
                        o_exit_from_l2<=0;
                        o_exit_from_l1<=0;
                        o_start_stall_hand<=0;
                    end        
                endcase
            end
        end

endmodule