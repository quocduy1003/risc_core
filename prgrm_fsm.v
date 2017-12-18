`include "risc.h"

module PRGRM_FSM (
	Clk,		// CPU Clock
	Reset,		// CPU Reset
	CurrentState	// Current State of FSM
);

input			Clk;		// CPU Clock
input			Reset;		// CPU Reset
output	`State_Type	CurrentState;	// Current State of FSM

reg `State_Type		Current_State, Next_State;

always @ (Reset or Current_State)
begin
  case (Current_State)		// synthesis full_case
    `RESET_STATE: 
	Next_State	= `FETCH_INSTR;
    `FETCH_INSTR:
	Next_State	= `READ_OPS;
    `READ_OPS:
	Next_State	= `EXECUTE;
    `EXECUTE:
	Next_State	= `WRITEBACK;
    `WRITEBACK:
	Next_State	= `FETCH_INSTR;
    default:
        Next_State	= `RESET_STATE;
  endcase
end

always @ (posedge Clk)
begin
  if (Reset)
    Current_State       <= `RESET_STATE;
  else
    Current_State       <= Next_State;
end

assign CurrentState = Current_State;

endmodule

