`include "risc.h"

module PRGRM_DECODE (
	Zro_Flag,
	Carry_Flag,
	Neg_Flag,
	CurrentState,
	Crnt_Instrn,
	Incrmnt_PC,
	Ld_Brnch_Addr,
	Ld_Rtn_Addr
);

input			Zro_Flag,	// "Zero" Flag from DATA_PATH
			Carry_Flag,	// "Carry" Flag from DATA_PATH
			Neg_Flag;	// "Negative" Flag from DATA_PATH

input `State_Type	CurrentState;	// CurrentState from FSM

input [31:0]		Crnt_Instrn;	// Current instruction under execution
					// from Instruction Latch

output			Incrmnt_PC,	// Increments PC (in WRITEBACK cycle)
			Ld_Brnch_Addr,	// Load Immediate add from Instrn Latch 
					// into PC (in WRITEBACK cycle)
			Ld_Rtn_Addr;	// Load Return addr from Stack into PC (in WRITEBACK cycle)

reg	Incrmnt_PC;

reg	Brnch_Addr, Rtn_Addr, Take_Branch;

reg	Neg, Carry, Zro, Jmp;

always @ (Take_Branch or CurrentState or Crnt_Instrn or 
          Zro_Flag or Carry_Flag or Neg_Flag or Brnch_Addr or Rtn_Addr)
begin

 //  Determine if Jmp on False or Jmp on True

  if (Crnt_Instrn[25])
  begin
    Neg		= ~Neg_Flag;
    Carry	= ~Carry_Flag;
    Zro		= ~Zro_Flag;
    Jmp		= 1'b0;
  end
  else
  begin
    Neg		= Neg_Flag;
    Carry	= Carry_Flag;
    Zro		= Zro_Flag;
    Jmp		= 1'b1;
  end

  //  Determines which of the CONDITIONs needs to be checked and whether to jmp

  if (Crnt_Instrn[23:16] == 8'b00000000)
    Take_Branch = Neg;
  else if (Crnt_Instrn[23:16] == 8'b00000001)
    Take_Branch = Zro;
  else if (Crnt_Instrn[23:16] == 8'b00000010)
    Take_Branch = Carry;
  else if (Crnt_Instrn[23:16] == 8'b00111111)
    Take_Branch = Jmp;
  else Take_Branch = 1'b0;

  case (CurrentState)
    `WRITEBACK: begin
      if (Crnt_Instrn[31:30] == 2'b00) // For Jmp/Call with condition check
      begin
        if ((Crnt_Instrn[29] | Crnt_Instrn[28]) & Take_Branch)
           Brnch_Addr	= 1'b1;
	else
           Brnch_Addr	= 1'b0;

        if (Crnt_Instrn[27])	// For Return
           Rtn_Addr	= 1'b1;
	else
           Rtn_Addr	= 1'b0;
      end
      else
      begin
        Brnch_Addr	= 1'b0;
        Rtn_Addr	= 1'b0;
      end
			        // If not Jmping or Rtrning the increment PC
      if (Rtn_Addr | Brnch_Addr)
         Incrmnt_PC	= 1'b0;
      else
         Incrmnt_PC	= 1'b1;
    end

    default: begin
      Incrmnt_PC	= 1'b0;	
      Brnch_Addr	= 1'b0;
      Rtn_Addr		= 1'b0;
    end
  endcase
end

assign Ld_Brnch_Addr	= Brnch_Addr;
assign Ld_Rtn_Addr	= Rtn_Addr;

endmodule

