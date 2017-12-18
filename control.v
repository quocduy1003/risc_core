`include "risc.h"

module CONTROL (
	Clk,
	Reset,
	Crnt_Instrn,
	Current_State,
	Neg_Flag,
	Carry_Flag,
	Zro_Flag,
	Latch_Instr,
	Rd_Oprnd_A,
	Rd_Oprnd_B,
	Latch_Flags,
	Latch_Result,
	Write_RegC,
	UseData_Imm_Or_RegB, 
	UseData_Imm_Or_ALU,
	Reset_AluRegs,
	EndOfInstrn,
	PushEnbl,
	PopEnbl,
	OUT_VALID
);
input		Clk,		// CPU Clock
                Reset;		// Reset to the cpu core

input [31:0]	Crnt_Instrn;	// Current instruction under execution;
				// from Instruction Latch

input `State_Type	Current_State;

input		Neg_Flag,
		Carry_Flag,
		Zro_Flag;

output		Latch_Instr,		// Enable for latching current instruction
		Rd_Oprnd_A,		// Latch operand A into reg at i/p of ALU
		Rd_Oprnd_B,		// Latch operand B into reg at i/p of ALU
		Latch_Flags,		// Enable for storing flags, only occurs
					// for ALU type instructions in Execute Clock 
		Latch_Result,		// Enable for latching o/p of ALU into latch 
		Write_RegC,		// Write for operand C (in execute cycle)

		UseData_Imm_Or_RegB, 
					// Select for mux between RegFile portB data
					// and Imm data (8-bit)

		UseData_Imm_Or_ALU,	// Select for mux between ALU o/p and
					// and Imm data to load to Register File
		Reset_AluRegs,    
					// Used to reset alu i/ps on every 
					// FETCH_INSTRN state
		EndOfInstrn,		// Used to dump PSW and RegFile contents into files at
					// end of every WRITE_BACK cycle
		PushEnbl,
		PopEnbl,
		OUT_VALID;		// to indicate that execution of DATA OUT 

reg		Latch_Instr,
		Rd_Oprnd_A,
		Rd_Oprnd_B,
		Latch_Flags,
		Latch_Result,
		Write_RegC,
		UseData_Imm_Or_RegB,
		UseData_Imm_Or_ALU,
		Reset_AluRegs,    
		EndOfInstrn,
		PushEnbl,
		PopEnbl,
		OUT_VALID;

reg Data_Imm_Or_ALU, Data_Imm_Or_RegB;
reg Take_Branch;

reg Neg, Carry, Zro, Jmp;

always @ (Crnt_Instrn or Neg_Flag or Carry_Flag or Zro_Flag)
begin 

  if (Crnt_Instrn[25])
  begin
	Neg	= ~Neg_Flag;
	Carry	= ~Carry_Flag;
	Zro	= ~Zro_Flag;
	Jmp	= 1'b0;
  end
  else 
  begin
	Neg	= Neg_Flag;
	Carry	= Carry_Flag;
	Zro	= Zro_Flag;
	Jmp	= 1'b1;
  end

  if (Crnt_Instrn[23:16] == 8'b00000000)
	Take_Branch = Neg;

  else if (Crnt_Instrn[23:16] == 8'b00000001)
	Take_Branch = Zro;

  else if (Crnt_Instrn[23:16] == 8'b00111111)
	Take_Branch = Jmp;

  else Take_Branch = 1'b0;

end

always @ (Reset or Current_State or Crnt_Instrn or Take_Branch)
begin

  case (Current_State)
    `RESET_STATE: begin
      PushEnbl		= 1'b0;
      PopEnbl		= 1'b0;
      Latch_Flags	= 1'b0;
      Latch_Result	= 1'b0;
      Rd_Oprnd_A	= 1'b0;
      Rd_Oprnd_B	= 1'b0;
      Data_Imm_Or_RegB	= 1'b0;
      Data_Imm_Or_ALU	= 1'b0;
      Latch_Instr	= 1'b0;
      Reset_AluRegs	= 1'b0;
      Write_RegC	= 1'b0;
      OUT_VALID		= 1'b0;
    end
    `FETCH_INSTR: begin 
      Data_Imm_Or_RegB  = 1'b0;
      Data_Imm_Or_ALU   = 1'b0;
      Latch_Instr       = 1'b1;
      Reset_AluRegs     = 1'b1;
      Write_RegC        = 1'b0;
      PushEnbl          = 1'b0;
      PopEnbl           = 1'b0;
      Latch_Flags       = 1'b0;
      Latch_Result      = 1'b0;
      Rd_Oprnd_A        = 1'b0;
      Rd_Oprnd_B        = 1'b0;
      OUT_VALID		= 1'b0;
    end
    `READ_OPS: begin
      Latch_Instr       = 1'b0;
      Reset_AluRegs     = 1'b0;
      PushEnbl          = 1'b0;
      PopEnbl           = 1'b0;
      Latch_Flags       = 1'b0;
      Latch_Result      = 1'b0;
      Write_RegC        = 1'b0;
      OUT_VALID		= 1'b0;

      // Generation of mux selects for data path and operand read signals
      // Asserting them in this state gives sufficient time for setup

      case (Crnt_Instrn[31:30])
        2'b00: begin		//    (Type 0 instruction)
                		// These 2 can actually be don't cares for Type 0
          Data_Imm_Or_RegB	= 1'b0;
          Data_Imm_Or_ALU	= 1'b0;
          Rd_Oprnd_A		= 1'b0;
          Rd_Oprnd_B		= 1'b0;
        end
        2'b01: begin		//    (Type 1 instruction)
          Data_Imm_Or_RegB	= 1'b0;
          Data_Imm_Or_ALU	= 1'b0;
          Rd_Oprnd_A		= 1'b1;
          Rd_Oprnd_B		= 1'b1;
        end
        2'b10: begin		//    (Type 2 instruction)
          Data_Imm_Or_RegB	= 1'b1;
          Data_Imm_Or_ALU	= 1'b0;
          Rd_Oprnd_A		= 1'b1;
          Rd_Oprnd_B		= 1'b1;
        end
        2'b11: begin		//    (Type 3 instruction)
          Data_Imm_Or_RegB	= 1'b0;
          Data_Imm_Or_ALU	= 1'b1;
          Rd_Oprnd_A		= 1'b0;
          Rd_Oprnd_B		= 1'b1;
        end
        default: begin
          Data_Imm_Or_RegB	= 1'b0;
          Data_Imm_Or_ALU	= 1'b0;
          Rd_Oprnd_A		= 1'b0;
          Rd_Oprnd_B		= 1'b0;
        end
      endcase
              
// Added by Anupam For reading the REG_FILE address given in instruction on user request
      if ( Crnt_Instrn[31:30] == 2'b00 & Crnt_Instrn[24] == 1'b1)
        Rd_Oprnd_A	= 1'b1;
    end 
    `EXECUTE: begin
	Rd_Oprnd_A       = 1'b0;
	Rd_Oprnd_B       = 1'b0;
	Latch_Instr      = 1'b0;
	Reset_AluRegs    = 1'b0;
	Write_RegC       = 1'b0;

	case (Crnt_Instrn[31:30])
          2'b00: begin	//    (Type 0 instruction)
                        // These 2 can actually be don't cares for Type 0
            Data_Imm_Or_RegB	= 1'b0;
            Data_Imm_Or_ALU	= 1'b0;
	  end

          2'b01: begin	//    (Type 1 instruction)
            Data_Imm_Or_RegB	= 1'b0;
            Data_Imm_Or_ALU	= 1'b0;
	  end

          2'b10: begin	//    (Type 2 instruction)
            Data_Imm_Or_RegB	= 1'b1;
            Data_Imm_Or_ALU	= 1'b0;
	  end

          2'b11: begin	//    (Type 3 instruction)
            Data_Imm_Or_RegB	= 1'b0;
            Data_Imm_Or_ALU	= 1'b1;
	  end

          default: begin
            Data_Imm_Or_RegB	= 1'b0;
            Data_Imm_Or_ALU	= 1'b0;
	  end
        endcase

	if ( Crnt_Instrn[31:30] == 2'b00 & Crnt_Instrn[24] == 1'b1)
          OUT_VALID = 1'b1;
	else
          OUT_VALID = 1'b0;

	// Push PC into Stack (Call Conditional)

	if ((Crnt_Instrn[31:30] == 2'b00 & Crnt_Instrn[28] == 1'b1) & Take_Branch)
          PushEnbl = 1'b1;
	else
          PushEnbl = 1'b0;

	// Pop from Stack (Return)

	if (Crnt_Instrn[31:30] == 2'b00 & Crnt_Instrn[27])
          PopEnbl = 1'b1;
	else
          PopEnbl = 1'b0;

	// Latching flags for ALU ops but not pass-thru ( ?? Can this be same as Latch_Result ??)

	if (Crnt_Instrn[31:30] == 2'b01 | Crnt_Instrn[31:30] == 2'b10)
          Latch_Flags = 1'b1;
	else
          Latch_Flags = 1'b0;

	// Latching result for ALU and pass-thru

	if (Crnt_Instrn[31:30] == 2'b01 |
	    Crnt_Instrn[31:30] == 2'b10 |
	    Crnt_Instrn[31:30] == 2'b11)
          Latch_Result = 1'b1;
	else
          Latch_Result = 1'b0;
      end

    `WRITEBACK: begin
      Latch_Flags	= 1'b0;
      Latch_Result	= 1'b0;
      PushEnbl		= 1'b0;
      PopEnbl		= 1'b0;
      Rd_Oprnd_A	= 1'b0;
      Rd_Oprnd_B	= 1'b0;
      Latch_Instr	= 1'b0;
      Reset_AluRegs	= 1'b0;
      OUT_VALID		= 1'b0;

	// Write result of ALU OP or the immediate data to reg_file

	if (Crnt_Instrn[31:30] != 2'b00)
          Write_RegC = 1'b1;
	else
          Write_RegC = 1'b0;

	case (Crnt_Instrn[31:30])
	  2'b00: begin	//    (Type 0 instruction)
                        // These 2 can actually be don't cares for Type 0
	    Data_Imm_Or_RegB	= 1'b0;
	    Data_Imm_Or_ALU	= 1'b0;
	  end

	  2'b01: begin	//    (Type 1 instruction)
	    Data_Imm_Or_RegB	= 1'b0;
	    Data_Imm_Or_ALU	= 1'b0;
	  end

	  2'b10: begin	//    (Type 2 instruction)
	    Data_Imm_Or_RegB	= 1'b1;
	    Data_Imm_Or_ALU	= 1'b0;
	  end

	  2'b11: begin	//    (Type 3 instruction)
	    Data_Imm_Or_RegB	= 1'b0;
	    Data_Imm_Or_ALU	= 1'b1;
	  end

	  default: begin
	    Data_Imm_Or_RegB	= 1'b0;
	    Data_Imm_Or_ALU	= 1'b0;
	  end
        endcase
    end
    default: begin
      Data_Imm_Or_ALU	= 1'b0;
      Data_Imm_Or_RegB	= 1'b0;
      Latch_Flags	= 1'b0;
      Latch_Instr	= 1'b0;
      Latch_Result	= 1'b0;
      OUT_VALID		= 1'b0;
      PopEnbl		= 1'b0;
      PushEnbl		= 1'b0;
      Rd_Oprnd_A	= 1'b0;
      Rd_Oprnd_B	= 1'b0;
      Reset_AluRegs	= 1'b0;
      Write_RegC	= 1'b0;
    end
  endcase
end

always @ (posedge Clk)
begin
  if (Reset) begin
    UseData_Imm_Or_RegB	<= 1'b0;
    UseData_Imm_Or_ALU  <= 1'b0;
  end
  else begin
    UseData_Imm_Or_RegB <= Data_Imm_Or_RegB;
    UseData_Imm_Or_ALU  <= Data_Imm_Or_ALU;
  end
end

// Added to generate signals which control file dump

always @ (posedge Clk)
begin
  if (Current_State == `WRITEBACK)
    EndOfInstrn <= 1'b1;
  else
    EndOfInstrn <= 1'b0;
end

endmodule

