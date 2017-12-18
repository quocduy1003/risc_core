`include "risc.h"

module RISC_CORE (
	Clk,
	Reset,
	Instrn,
	Xecutng_Instrn,
	EndOfInstrn,
	PSW,
	Rd_Instr,
	RESULT_DATA,
	OUT_VALID,
	STACK_FULL,
        I_STACK_TOP_on,
 	I_REG_FILE_on,
 	enable_signal2,
	enable_signal3
);

input		Clk;
input		Reset;
input	[31:0]	Instrn;
input	 I_STACK_TOP_on;
input	 I_REG_FILE_on;
input    enable_signal2;
input    enable_signal3;
output	[31:0]	Xecutng_Instrn;
output		EndOfInstrn;
output	[10:0]	PSW;
output		Rd_Instr;
output	[15:0]	RESULT_DATA;
output		OUT_VALID;
output		STACK_FULL;


wire	[15:0]	Oprnd_A, Oprnd_B, Op_Result, RegPort_A, RegPort_B, RegPort_C;

wire	[6:0]	Addr_A, Addr_B, Addr_C;

wire	[5:0]	ALU_OP;

wire	ALU_Zro, ALU_Neg, ALU_Carry, Zro_Flag, Neg_Flag, Carry_Flag,
           PSW_Zro, PushEnbl, PopEnbl, PSW_Neg, PSW_Carry, 
           Write_RegC, Rd_Oprnd_A, Rd_Oprnd_B, Latch_Instr, Latch_Flags,
           Latch_Result, UseData_Imm_Or_RegB, UseData_Imm_Or_ALU, 
           Reset_AluRegs;

wire	`State_Type	Current_State;

wire	[31:0]	Crnt_Instrn_1, Crnt_Instrn_2;
wire	[11:0]	PushDataIn, PopDataOut;
wire	[7:0]	Return_Addr, Imm_Addr;
wire	[7:0]	PC;
wire	 I_STACK_TOP_on;
wire	 I_REG_FILE_on;


// begin

// Connectivity definition of components

assign PushDataIn 	=  {8'b00000000, Zro_Flag, Neg_Flag, Carry_Flag, PC};
assign Return_Addr 	=  PopDataOut[7:0];
assign PSW_Zro 		=  PopDataOut[10];
assign PSW_Neg 		=  PopDataOut[9];
assign PSW_Carry 	=  PopDataOut[8];
assign ALU_OP 		=  Crnt_Instrn_1[29:24];
assign Addr_B 		=  Crnt_Instrn_1[6:0];
assign Addr_C 		=  Crnt_Instrn_1[22:16];
assign PSW 		=  {PC, Zro_Flag, Neg_Flag, Carry_Flag};
assign Rd_Instr 	=  Latch_Instr;
assign Xecutng_Instrn 	=  Crnt_Instrn_1;
assign RESULT_DATA 	=  RegPort_A; 
           
// Entity instantiations

ALU I_ALU (
	.Reset		(Reset),
	.Clk		(Clk),
	.Oprnd_A	(Oprnd_A),
	.Oprnd_B	(Oprnd_B),
	.ALU_OP		(ALU_OP),
	.Latch_Result	(Latch_Result),
	.Latch_Flags	(Latch_Flags),
	.Lachd_Result	(Op_Result),
	.Zro_Flag	(ALU_Zro),
	.Neg_Flag	(ALU_Neg),
	.Carry_Flag	(ALU_Carry)
 );

CONTROL I_CONTROL (
	.Clk 		(Clk),
	.Reset 		(Reset),
	.Crnt_Instrn 	(Crnt_Instrn_2),
	.Current_State	(Current_State),
	.Neg_Flag	(Neg_Flag),
	.Carry_Flag	(Carry_Flag),
	.Zro_Flag	(Zro_Flag),
	.Latch_Instr 	(Latch_Instr),
	.Rd_Oprnd_A 	(Rd_Oprnd_A),
	.Rd_Oprnd_B 	(Rd_Oprnd_B),
	.Latch_Flags 	(Latch_Flags), 
	.Latch_Result 	(Latch_Result),
	.Write_RegC 	(Write_RegC),
	.UseData_Imm_Or_RegB 	(UseData_Imm_Or_RegB),
	.UseData_Imm_Or_ALU 	(UseData_Imm_Or_ALU),
	.Reset_AluRegs	(Reset_AluRegs),
	.EndOfInstrn 	(EndOfInstrn),
	.PushEnbl 	(PushEnbl),
	.PopEnbl 	(PopEnbl),
	.OUT_VALID 	(OUT_VALID)
);

DATA_PATH I_DATA_PATH (
	.Clk 		(Clk),
	.Reset 		(Reset),
	.Reset_AluRegs 	(Reset_AluRegs),
	.Rd_Oprnd_A 	(Rd_Oprnd_A),
	.Rd_Oprnd_B 	(Rd_Oprnd_B),
	.UseData_Imm_Or_RegB 	(UseData_Imm_Or_RegB),
	.UseData_Imm_Or_ALU 	(UseData_Imm_Or_ALU),
	.Latch_Flags 	(Latch_Flags),
	.ALU_Zro 	(ALU_Zro),
	.ALU_Neg 	(ALU_Neg),
	.ALU_Carry 	(ALU_Carry),
	.PSW_Zro 	(PSW_Zro),
	.PSW_Neg 	(PSW_Neg),
	.PSW_Carry 	(PSW_Carry),
	.Crnt_Instrn 	(Crnt_Instrn_2),
	.RegPort_A 	(RegPort_A),
	.RegPort_B 	(RegPort_B),
	.Op_Result 	(Op_Result),
	.Zro_Flag 	(Zro_Flag),
	.Neg_Flag 	(Neg_Flag),
	.Carry_Flag 	(Carry_Flag),
	.Addr_A 	(Addr_A),
	.Oprnd_A 	(Oprnd_A),
	.Oprnd_B 	(Oprnd_B),
	.RegPort_C 	(RegPort_C)
);

INSTRN_LAT I_INSTRN_LAT (
	.Clk 		(Clk),
	.Instrn 	(Instrn),
	.Latch_Instr 	(Latch_Instr),
	.Crnt_Instrn_1	(Crnt_Instrn_1),
	.Crnt_Instrn_2	(Crnt_Instrn_2)
);

PRGRM_CNT_TOP I_PRGRM_CNT_TOP (
	.Clk 		(Clk),
	.Reset 		(Reset),
	.Crnt_Instrn	(Crnt_Instrn_2),
	.Zro_Flag	(Zro_Flag),
	.Carry_Flag	(Carry_Flag),
	.Neg_Flag	(Neg_Flag),
	.Return_Addr 	(Return_Addr),
	.Current_State	(Current_State),
	.PC 		(PC)
);

REG_FILE I_REG_FILE (
	.Reset 		(Reset),
	.Clk 		(Clk),
	.Addr_A 	(Addr_A),
	.Addr_B 	(Addr_B),
	.Addr_C 	(Addr_C),
	.RegPort_C 	(RegPort_C),
	.Write_RegC 	(Write_RegC),
	.RegPort_A 	(RegPort_A),
	.RegPort_B 	(RegPort_B),
	.enable_signal	(enable_signal2)
);

STACK_TOP I_STACK_TOP (
	.Reset 		(Reset),
	.Clk 		(Clk),
	.PushEnbl 	(PushEnbl),
	.PopEnbl 	(PopEnbl),
	.PushDataIn 	(PushDataIn),
	.PopDataOut 	(PopDataOut),
	.STACK_FULL 	(STACK_FULL),
	.enable_signal	 (enable_signal3)
);

endmodule

