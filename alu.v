`include "risc.h"

module  ALU (
	Reset, Clk,
	Oprnd_A,
	Oprnd_B,
	ALU_OP,
	Latch_Result,
	Latch_Flags,
	Lachd_Result,
	Zro_Flag,
	Neg_Flag,
	Carry_Flag
);

input		Reset, Clk;
input [15:0]	Oprnd_A,	// Operand A, from RegFile
		Oprnd_B;	// Operand B, from RegFile or current inst

input [5:0]	ALU_OP;		// Code from OP field of Instruction

input		Latch_Result,
		Latch_Flags;

output [15:0]	Lachd_Result;	// Result of performing OP on operands 

output		Zro_Flag,	// Zero flag
		Neg_Flag,	// Negative result flag 
		Carry_Flag;	// Carry out flag

reg [15:0]	Lachd_Result;

reg		Zro_Flag,
		Neg_Flag,
		Carry_Flag;

reg [15:0]	Op_Result;
reg		ALU_Zro, ALU_Carry, ALU_Neg;
reg [15:0]	Result;
reg [16:0]	SignedResult;

always @ (posedge Clk)
begin
  if (Latch_Result)
    Lachd_Result <= Op_Result;
 
  if (Reset) begin
    Zro_Flag	<= 1'b0;
    Neg_Flag	<= 1'b0;
    Carry_Flag	<= 1'b0;
  end
  else if (Latch_Flags) begin
    Zro_Flag	<= ALU_Zro;
    Neg_Flag	<= ALU_Neg;
    Carry_Flag	<= ALU_Carry;
  end
end
	
// ALU Operations

always @ (Oprnd_A or Oprnd_B or ALU_OP)
begin: Decode

  case (ALU_OP)			// synthesis parallel_case
    `OP_ADD:
      Result = Oprnd_A + Oprnd_B;

    `OP_ADD_PLUS_ONE:
      Result = Oprnd_A + Oprnd_B + 1;

    `OP_A, `OP_Ap, `OP_App:
      Result = Oprnd_A;

    `OP_A_PLUS_ONE:
      Result = Oprnd_A + 1;

    `OP_SUB:
      Result = Oprnd_A - Oprnd_B;

    `OP_SUB_MINUS_ONE:
      Result = Oprnd_A - Oprnd_B + 1;

    `OP_A_MINUS_ONE:
      Result = Oprnd_A - 1;

    `OP_ALL_ZEROS:
      Result = 16'b0000000000000000;

    `OP_A_AND_B:
      Result = Oprnd_A & Oprnd_B;

    `OP_notA_AND_B:
      Result = ~Oprnd_A & Oprnd_B;

    `OP_B:
      Result = Oprnd_B;

    `OP_notA_AND_notB:
      Result = ~Oprnd_A & ~Oprnd_B;

    `OP_A_XNOR_B:
      Result = ~(Oprnd_A ^ Oprnd_B);

    `OP_notA:
      Result = ~Oprnd_A;

    `OP_notA_OR_B:
      Result = ~Oprnd_A | Oprnd_B;

    `OP_A_AND_notB:
      Result = Oprnd_A & ~Oprnd_B;

    `OP_A_XOR_B:
      Result = Oprnd_A ^ Oprnd_B;

    `OP_A_OR_B:
      Result = Oprnd_A | Oprnd_B;

    `OP_notB:
      Result = ~Oprnd_B;

    `OP_A_OR_notB:
      Result = Oprnd_A | ~Oprnd_B;

    `OP_A_NAND_B:
      Result = ~(Oprnd_A & Oprnd_B);

    `OP_ALL_ONES:
      Result = 16'b1111111111111111;

            // When non-ALU ops don't generate errors
    default:
      Result = 16'b0000000000000000;
  endcase

  if (Result == 16'b0000000000000000)
    ALU_Zro = 1'b1;
  else
    ALU_Zro = 1'b0;

  if (Result < 0)
    ALU_Neg = 1'b1;
  else
    ALU_Neg = 1'b0;

  ALU_Carry = 1'b0;

  Op_Result = Result;

end
endmodule


