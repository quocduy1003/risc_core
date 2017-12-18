module  STACK_FSM ( 
	Reset,
	Clk,
	PushEnbl,
	PopEnbl,
	TOS,
	STACK_FULL
);
input		Reset,		// Reset
		Clk,		// Clock
		PushEnbl,	// Push cmd for stack
		PopEnbl;	// Pop cmd for stack

output [0:2]	TOS;		// Stack address
output		STACK_FULL;	// Stack is full

reg		STACK_FULL;

`define Stack_State [1:0]
`define EMPTY	2'b00
`define NORMAL	2'b01
`define FULL	2'b11
`define ERROR	2'b10

reg `Stack_State	Crnt_Stack, Next_Stack;
reg [0:2]		 Next_TOS, TOS_int;

always @ (Crnt_Stack or TOS_int or PushEnbl or PopEnbl)
begin
  if (PushEnbl & PopEnbl) begin
    Next_Stack	= `ERROR;
    Next_TOS	= 3'b000;
  end
  else
    case (Crnt_Stack)
      `EMPTY: begin
	if (PushEnbl) begin  
	  Next_Stack	= `NORMAL;
	  Next_TOS	= 3'b001;
	end
	else if (PopEnbl) begin
	  Next_Stack	= `ERROR;
	  Next_TOS	= 3'b000;
	end
	else begin
	  Next_Stack	= `EMPTY;
	  Next_TOS	= 3'b000;
	end
      end
      `NORMAL: begin
	if (PushEnbl) begin
	  if (TOS_int == 3'b111) begin
	    Next_Stack	= `FULL;
	    Next_TOS	= 3'b111;
	  end
	  else begin
	    Next_Stack	= `NORMAL;
	    Next_TOS	= TOS_int + 1;
	  end 
	end
	else if (PopEnbl) begin
	  if (TOS_int == 3'b001) begin
	    Next_Stack	= `EMPTY;
	    Next_TOS	= 3'b000;
	  end
	  else begin
	    Next_Stack	= `NORMAL;
	    Next_TOS	= TOS_int - 1;
	  end
	end
	else begin
	  Next_Stack	= `NORMAL;
	  Next_TOS	= TOS_int;
	end
      end
      `FULL: begin
	if (PushEnbl) begin
	  Next_Stack	= `ERROR;
	  Next_TOS	= 3'b111;
	end
	else if (PopEnbl) begin
	  Next_Stack	= `NORMAL;
	  Next_TOS	= 3'b111;
	end
	else begin
	  Next_Stack	= `FULL;
	  Next_TOS	= 3'b111;
	end 
      end
      `ERROR: begin
	 Next_Stack	= `ERROR ;
	 Next_TOS	= 3'b111;
      end
    endcase
end

always @ (posedge Clk)
begin
  if (Reset) begin
    Crnt_Stack	<= `EMPTY;
    TOS_int	<= 3'b000;
  end
  else begin
    Crnt_Stack	<= Next_Stack;
    TOS_int	<= Next_TOS;
    if (Crnt_Stack == `FULL & TOS_int == 3'b111)
      STACK_FULL <= 1'b1;
    else
      STACK_FULL <= 1'b0; 
  end
end

assign TOS = TOS_int;

endmodule
