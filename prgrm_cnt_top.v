`include "risc.h"

module PRGRM_CNT_TOP (
	Clk,
	Reset,
	Crnt_Instrn,
	Zro_Flag,
	Carry_Flag,
	Neg_Flag,
	Return_Addr,
	Current_State,
	PC
);

input			Clk;
input			Reset;
input [31:0]		Crnt_Instrn;	// Current Executing Inst
input			Zro_Flag,	// Flags from ALU or Stack
			Carry_Flag,
			Neg_Flag;
input [7:0]		Return_Addr;
output	`State_Type	Current_State;	// CurrentState from Control FSM  
output	[7:0]		PC;

wire  			Incrmnt_PC, Ld_Brnch_Addr, Ld_Rtn_Addr;
wire `State_Type 	CurrentState; 

PRGRM_FSM I_PRGRM_FSM (
	.Clk		(Clk),
	.Reset		(Reset),
	.CurrentState 	(CurrentState)
);

PRGRM_DECODE I_PRGRM_DECODE (
	.Zro_Flag	(Zro_Flag),
	.Carry_Flag	(Carry_Flag),
	.Neg_Flag	(Neg_Flag),
	.CurrentState	(CurrentState),
	.Crnt_Instrn	(Crnt_Instrn),
	.Incrmnt_PC	(Incrmnt_PC),
	.Ld_Brnch_Addr	(Ld_Brnch_Addr),
	.Ld_Rtn_Addr	(Ld_Rtn_Addr)
);

PRGRM_CNT I_PRGRM_CNT (
	.Reset		(Reset),
	.Clk		(Clk),
	.Incrmnt_PC	(Incrmnt_PC),
	.Ld_Brnch_Addr	(Ld_Brnch_Addr),
	.Ld_Rtn_Addr	(Ld_Rtn_Addr),
	.Imm_Addr	(Crnt_Instrn[7:0]),
	.Return_Addr	(Return_Addr),
	.PC		(PC)
);

assign Current_State = CurrentState;

endmodule
				 	
