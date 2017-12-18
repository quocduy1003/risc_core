`include "risc.h"

module  DATA_PATH ( 
	Clk,
	Reset,
	Reset_AluRegs,
	Rd_Oprnd_A,
	Rd_Oprnd_B,
	UseData_Imm_Or_RegB,
	UseData_Imm_Or_ALU,
	Latch_Flags,
	ALU_Zro,
	ALU_Neg,
	ALU_Carry,
	PSW_Zro,
	PSW_Neg,
	PSW_Carry,
	Crnt_Instrn,
	RegPort_A,
	RegPort_B,
	Op_Result,
	Zro_Flag,
	Neg_Flag,
	Carry_Flag,
	Addr_A,
	Oprnd_A,
	Oprnd_B,
	RegPort_C
);

input		Clk,			// Clock
		Reset,			// Reset for flags
		Reset_AluRegs,		// Reset alu port registers
		Rd_Oprnd_A,		// From CONTROL;Commands to read operand A & B
		Rd_Oprnd_B,		// into regs at i/p of ALU
		UseData_Imm_Or_RegB,	// Selects Immediate Data(8-bit) from Instrn 
			   		// Latch or from Reg File PortB for ALU input
		UseData_Imm_Or_ALU,	// Selects Immediate Data(16-bit) from Instrn
					// Latch or from ALU Result
		Latch_Flags,		// Enable for latching flags
		ALU_Zro,		// ALU o/p 
		ALU_Neg,		// ALU o/p 
		ALU_Carry,		// ALU o/p 
		PSW_Zro,		// Stack value of Zro flag
		PSW_Neg,		// Stack value of Neg flag
		PSW_Carry;		// Stack value of Carry flag
            
input [31:0]	Crnt_Instrn;		// Instrn under execution from INSTRN_LAT

input [15:0]	RegPort_A,		// RegFile portA data o/p;latched & fed to ALU
		RegPort_B,		// RegFile portB data o/p;latched & fed to ALU
		Op_Result;		// ALU result; latched, then  muxed with 
					// DataImmediate from INSTRN_LAT to feed 
					// the RegFile as RegPort_C

output		Zro_Flag,		// Latched flag 
		Neg_Flag,		// Latched flag
		Carry_Flag;		// Latched flag (Not implemented )

output [6:0]	Addr_A;			// to calculate address for REG_FILE port A  

output [15:0]	Oprnd_A,		// Fed to ALU portA
		Oprnd_B,		// Fed to ALU portB
		RegPort_C;		// I/p to RegFile portC

reg		Zro_Flag,
		Neg_Flag,
		Carry_Flag;

reg [6:0]	Addr_A;

reg [15:0]	Oprnd_A,
		Oprnd_B,
		RegPort_C;

reg	PSWL_Zro, PSWL_Carry, PSWL_Neg;

always @ (posedge Clk)
begin

// Register at ALU input A

	if (Reset_AluRegs)
            Oprnd_A <= 16'b0000000000000000;
        else if (Rd_Oprnd_A)
            Oprnd_A <= RegPort_A;

// Register at ALU input B (Muxing with imm data included here)

        if (Reset_AluRegs)
            Oprnd_B <= 16'b0000000000000000;
        else if (Rd_Oprnd_B) begin
            if (UseData_Imm_Or_RegB)
                Oprnd_B <= {8'b00000000, Crnt_Instrn[7:0]};
            else if (~UseData_Imm_Or_RegB)
                Oprnd_B <= RegPort_B;
	end

        if (Reset) begin
            PSWL_Zro <= 1'b0;
            PSWL_Neg <= 1'b0;
            PSWL_Carry <= 1'b0;
	end
        else if (Latch_Flags) begin
	    PSWL_Zro <= PSW_Zro;
            PSWL_Neg <= PSW_Neg;
	    PSWL_Carry <= PSW_Carry;
        end
            
end

// Mux between latched ALU Result and Immediate data to be loaded into RegFile

always @ (Crnt_Instrn or Op_Result or UseData_Imm_Or_ALU)
begin
       if (UseData_Imm_Or_ALU)
           RegPort_C = Crnt_Instrn[15:0];
       else
           RegPort_C = Op_Result;
end

// Muxing of flags betn popped and ALU outputs - Return instrn alone requires popped flags

always @ (Crnt_Instrn or PSWL_Zro or PSWL_Neg or PSWL_Carry or ALU_Zro or ALU_Neg or ALU_Carry)
begin
        if (Crnt_Instrn[31:24] == 8'b00001000) begin
            Zro_Flag   = PSWL_Zro;
            Neg_Flag   = PSWL_Neg;
            Carry_Flag = PSWL_Carry;
	end
        else begin
            Zro_Flag   = ALU_Zro;
            Neg_Flag   = ALU_Neg;
            Carry_Flag = ALU_Carry;
        end
end

// Added by Anupam to calculate Address for port_A of REG_FILE

always @ (Crnt_Instrn)
begin
       if (Crnt_Instrn[31:30] == 2'b00 & Crnt_Instrn[24] == 1'b1)
          Addr_A = Crnt_Instrn[6:0];
       else
          Addr_A = Crnt_Instrn[14:8];
end

endmodule
