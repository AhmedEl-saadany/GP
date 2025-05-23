package pkg;

	typedef enum {RESET, SBINIT, MBINIT, MBTRAIN, LINKINIT, ACTIVE, PHYRETRAIN, TRAINERROR} state_e;
	
	typedef enum {PARAM, CAL, REPAIRCLK, REPAIRVAL, REVERSALMB, REPAIRMB} MBINIT_SubState_e;
	
	typedef enum {VALREF, DATAVREF, SPEEDIDLE, TXSELFCAL, RXCLKCAL, VALTRAINCENTER, VALTRAINVREF, DATATRAINCENTER1, DATATRAINVREF,RXDESKEW, DATATRAINCENTER2, LINKSPEED, REPAIR} MBTRAIN_SubState_e;
	
	typedef enum {	SBINIT_DONE_REQ = 1,
					SBINIT_DONE_RESP,
					SBINIT_OUT_OF_RESET} SBINIT_MSG_e;

	typedef enum {	MBINIT_PARAM_CONFIGURATION_REQ = 1, 
					MBINIT_PARAM_CONFIGURATION_RESP} MBINIT_PARAM_MSG_e;
	
	typedef enum {	MBINIT_CAL_DONE_REQ = 1, 
					MBINIT_CAL_DONE_RESP} MBINIT_CAL_MSG_e;
	
	typedef enum logic 	[3:0]	 {	MBINIT_REPAIRCLK_INIT_REQ = 1, 
				  					MBINIT_REPAIRCLK_INIT_RESP,
				  					MBINIT_REPAIRCLK_RESULT_REQ,
	 			  					MBINIT_REPAIRCLK_RESULT_RESP,
	 			  					MBINIT_REPAIRCLK_DONE_REQ,
	 			  					MBINIT_REPAIRCLK_DONE_RESP} MBINIT_REPAIRCLK_MSG_e;

	typedef enum logic 	[3:0]	 {	MBINIT_REPAIRVAL_INIT_REQ = 1,
				  					MBINIT_REPAIRVAL_INIT_RESP,
				  					MBINIT_REPAIRVAL_RESULT_REQ,
				  					MBINIT_REPAIRVAL_RESULT_RESP,
				  					MBINIT_REPAIRVAL_DONE_REQ,
				  					MBINIT_REPAIRVAL_DONE_RESP} MBINIT_REPAIRVAL_MSG_e;

	typedef enum logic 	[3:0]	 {	MBINIT_REVERSALMB_INIT_REQ = 1,	
									MBINIT_REVERSALMB_INIT_RESP, 	
									MBINIT_REVERSALMB_CLEAR_ERROR_REQ,
									MBINIT_REVERSALMB_CLEAR_ERROR_RESP,
									MBINIT_REVERSALMB_RESULT_REQ ,
									MBINIT_REVERSALMB_RESULT_RESP, 
									MBINIT_REVERSALMB_DONE_REQ ,	
									MBINIT_REVERSALMB_DONE_RESP} MBINIT_REVERSALMB_MSG_e;

	typedef enum logic 	[3:0]	 {	MBINIT_REPAIRMB_START_REQ = 1, 	
									MBINIT_REPAIRMB_START_RESP, 	
									MBINIT_REPAIRMB_END_REQ, 		
									MBINIT_REPAIRMB_END_RESP, 	
									MBINIT_REPAIRMB_APPLY_DEGRADE_REQ,
									MBINIT_REPAIRMB_APPLY_DEGRADE_RESP} MBINIT_REPAIRMB_MSG_e;
	
	typedef enum logic 	[3:0]	 {	MBTRAIN_VALVREF_START_REQ = 1, 	
									MBTRAIN_VALVREF_START_RESP, 	
									MBTRAIN_VALVREF_END_REQ, 		
									MBTRAIN_VALVREF_END_RESP} MBTRAIN_VALVREF_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_DATAVREF_START_REQ = 1, 	
									MBTRAIN_DATAVREF_START_RESP, 	
									MBTRAIN_DATAVREF_END_REQ, 		
									MBTRAIN_DATAVREF_END_RESP} MBTRAIN_DATAVREF_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_SPEEDIDLE_DONE_REQ = 1, 	
									MBTRAIN_SPEEDIDLE_DONE_RESP} MBTRAIN_SPEEDIDLE_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_TXSELFCAL_DONE_REQ = 1, 	
									MBTRAIN_TXSELFCAL_DONE_RESP} MBTRAIN_TXSELFCAL_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_RXCLKCAL_START_REQ = 1, 	
									MBTRAIN_RXCLKCAL_START_RESP, 		
									MBTRAIN_RXCLKCAL_DONE_REQ, 		
									MBTRAIN_RXCLKCAL_DONE_RESP} MBTRAIN_RXCLKCAL_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_VALTRAINCENTER_START_REQ = 1, 	
									MBTRAIN_VALTRAINCENTER_START_RESP, 		
									MBTRAIN_VALTRAINCENTER_DONE_REQ, 		
									MBTRAIN_VALTRAINCENTER_DONE_RESP} MBTRAIN_VALTRAINCENTER_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_VALTRAINVREF_START_REQ = 1, 	
									MBTRAIN_VALTRAINVREF_START_RESP, 		
									MBTRAIN_VALTRAINVREF_DONE_REQ, 		
									MBTRAIN_VALTRAINVREF_DONE_RESP} MBTRAIN_VALTRAINVREF_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_DATATRAINCENTER1_START_REQ = 1, 	
									MBTRAIN_DATATRAINCENTER1_START_RESP, 	
									MBTRAIN_DATATRAINCENTER1_END_REQ, 		
									MBTRAIN_DATATRAINCENTER1_END_RESP} MBTRAIN_DATATRAINCENTER1_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_DATATRAINVREF_START_REQ = 1, 	
									MBTRAIN_DATATRAINVREF_START_RESP, 	
									MBTRAIN_DATATRAINVREF_END_REQ, 		
									MBTRAIN_DATATRAINVREF_END_RESP} MBTRAIN_DATATRAINVREF_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_RXDESKEW_START_REQ = 1, 	
									MBTRAIN_RXDESKEW_START_RESP, 	
									MBTRAIN_RXDESKEW_END_REQ, 		
									MBTRAIN_RXDESKEW_END_RESP} MBTRAIN_RXDESKEW_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_DATATRAINCENTER2_START_REQ = 1, 	
									MBTRAIN_DATATRAINCENTER2_START_RESP, 	
									MBTRAIN_DATATRAINCENTER2_END_REQ, 		
									MBTRAIN_DATATRAINCENTER2_END_RESP} MBTRAIN_DATATRAINCENTER2_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_LINKSPEED_START_REQ = 1, 	
									MBTRAIN_LINKSPEED_START_RESP, 	
									MBTRAIN_LINKSPEED_ERROR_REQ, 		
									MBTRAIN_LINKSPEED_ERROR_RESP,
									MBTRAIN_LINKSPEED_EXIT_TO_REPAIR_REQ, 		
									MBTRAIN_LINKSPEED_EXIT_TO_REPAIR_RESP,
									MBTRAIN_LINKSPEED_EXIT_TO_SPEED_DEDRADE_REQ, 		
									MBTRAIN_LINKSPEED_EXIT_TO_SPEED_DEDRADE_RESP,
									MBTRAIN_LINKSPEED_DONE_REQ, 		
									MBTRAIN_LINKSPEED_DONE_RESP} MBTRAIN_LINKSPEED_MSG_e;
									//MBTRAIN_LINKSPEED_EXIT_TO_PHY_RETRAIN_REQ, 		
									//MBTRAIN_LINKSPEED_EXIT_TO_PHY_RETRAIN_RESP} MBTRAIN_LINKSPEED_MSG_e;

	typedef enum logic 	[3:0]	 {	MBTRAIN_REPAIR_INIT_REQ = 1, 	
									MBTRAIN_REPAIR_INIT_RESP, 	
									MBTRAIN_REPAIR_APPLY_REPAIR_REQ, 		
									MBTRAIN_REPAIR_APPLY_REPAIR_RESP,
									MBTRAIN_REPAIR_END_REQ, 	
									MBTRAIN_REPAIR_END_RESP,
									MBTRAIN_REPAIR_APPLY_DEGRADE_REQ,
									MBTRAIN_REPAIR_APPLY_DEGRADE_RESP} MBTRAIN_REPAIR_MSG_e;

	typedef enum logic 	[3:0]	 {	PHYRETRAIN_RETRAIN_START_REQ = 1, 	
									PHYRETRAIN_RETRAIN_START_RESP} PHYRETRAIN_MSG_e;	

		
	state_e 						GenStates;
	state_e 						GenStates_DRV;	
	MBINIT_SubState_e 				MBINIT_SubStates;
	MBINIT_SubState_e 				MBINIT_SubStates_DRV;
	MBTRAIN_SubState_e 				MBTRAIN_SubStates;
	MBTRAIN_SubState_e 				MBTRAIN_SubStates_DRV;


	SBINIT_MSG_e 					SBINIT_MSGs;

	MBINIT_PARAM_MSG_e 		 		MBINIT_PARAM_MSGs;
	MBINIT_CAL_MSG_e   				MBINIT_CAL_MSGs;
	MBINIT_REPAIRCLK_MSG_e  		MBINIT_REPAIRCLK_MSGs;
	MBINIT_REPAIRVAL_MSG_e  		MBINIT_REPAIRVAL_MSGs;
	MBINIT_REVERSALMB_MSG_e 		MBINIT_REVERSALMB_MSGs;
	MBINIT_REPAIRMB_MSG_e 			MBINIT_REPAIRMB_MSGs;

	MBTRAIN_VALVREF_MSG_e 			MBTRAIN_VALVREF_MSGs;
	MBTRAIN_DATAVREF_MSG_e 			MBTRAIN_DATAVREF_MSGs;
	MBTRAIN_SPEEDIDLE_MSG_e 		MBTRAIN_SPEEDIDLE_MSGs;
	MBTRAIN_TXSELFCAL_MSG_e 		MBTRAIN_TXSELFCAL_MSGs;
	MBTRAIN_RXCLKCAL_MSG_e 			MBTRAIN_RXCLKCAL_MSGs;
	MBTRAIN_VALTRAINCENTER_MSG_e 	MBTRAIN_VALTRAINCENTER_MSGs;
	MBTRAIN_VALTRAINVREF_MSG_e 		MBTRAIN_VALTRAINVREF_MSGs;
	MBTRAIN_DATATRAINCENTER1_MSG_e 	MBTRAIN_DATATRAINCENTER1_MSGs;
	MBTRAIN_DATATRAINVREF_MSG_e 	MBTRAIN_DATATRAINVREF_MSGs;
	MBTRAIN_RXDESKEW_MSG_e 			MBTRAIN_RXDESKEW_MSGs;
	MBTRAIN_DATATRAINCENTER2_MSG_e 	MBTRAIN_DATATRAINCENTER2_MSGs;
	MBTRAIN_LINKSPEED_MSG_e 		MBTRAIN_LINKSPEED_MSGs;
	MBTRAIN_REPAIR_MSG_e 			MBTRAIN_REPAIR_MSGs;

	PHYRETRAIN_MSG_e 				PHYRETRAIN_MSGs;
	
endpackage : pkg