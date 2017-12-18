module STACK_MEM ( 
	Clk,
	PushEnbl,
	PopEnbl,
	Stack_Full,
	TOS,
	PushDataIn,
	PopDataOut
);
input		Clk,		// Clock
		PushEnbl,	// Push cmd for stack
		PopEnbl,	// Pop cmd for stack
		Stack_Full;	// Stack is full flag	

input [0:2]	TOS;

input [3:0]	PushDataIn;	// Data to be pushed into the stack 

output [3:0]	PopDataOut;	// Data popped out of the stack

reg [3:0]	PopDataOut;

reg [3:0]	Stack_Mem [0:7];

reg [0:2]	Pop_Address;

// Generate Correct Address for Pop

always @ (Stack_Full or TOS)
begin
  if (Stack_Full)
    Pop_Address = TOS;
  else
    Pop_Address = TOS - 1;
end

// Stack Memory writes; described as a set of registers (edge sensitive)

always @ (posedge Clk)
begin
  if (PushEnbl)
    Stack_Mem[TOS] <= PushDataIn;
end

// Stack Memory reads; the output is latched every clock edge

always @ (posedge Clk)
begin
  if (PopEnbl)
    PopDataOut <= Stack_Mem[Pop_Address];
end

endmodule
