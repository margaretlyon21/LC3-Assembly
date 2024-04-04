                .ORIG x3000
;First, the data/strings that i will use 
INSTRUCTIONS	.STRINGZ "\nInstructions to move n disks from post 1 to post 3: \n"
PROMPT	        .STRINGZ "--Towers of Hanoi--\n"
DISKPROMPT		.STRINGZ "How many disks (1-9)?"
STEP            .STRINGZ "Move disk n from post a to post b \n"
ASCII_OFFSET    .FILL #48
STACK   		.FILL x5000 
START   		.FILL #1	
MID 			.FILL #2	
ENDPOST     	.FILL #3   

;Main()
	LEA R0, PROMPT  	;Loads address of "Towers of Hanoi." string into R0 and prints it
	PUTS 				
	LEA R0, DISKPROMPT	;Loads address of "Number of disks," string into r0 and prints it 
	PUTS				;
	GETC				;Gets the number of disks to use from the user and then displays the input
	OUT	
	LD R1, ASCII_OFFSET		;Loads the ASCII offset to R1
	ADD R2,R1, #0           ;gets the hex for the ascii character
	NOT R2,R2			
	ADD R2,R2,#1			
	ADD R0,R2,R0            ;puts hex in r0
	LD R3,STACK     		;Loads the address of the bottom of the stack 
	STR R0,R3,#0			;Stores contents of r0 at address in r3 - puts n disks on the stack
	LEA R0, INSTRUCTIONS	;puts instructions in r0 and prints them		
	PUTS

;Function call for movedisk() in main - caller portion	
	LD R5,STACK     		;R5 = x5000
	LD R6,STACK     		;R6 = x5000
	;arguments
	LD R1,START			    ;R1 = x0001	
	LD R2,ENDPOST			;R2 = x0003
	LD R3,MID			    ;R3 = x0002
	
	;Push arguments to stack				
	ADD R6,R6,#-1					
	STR R3,R6,#0			; x0002 is added to stack
	ADD R6,R6,#-1			
	STR R2,R6,#0			;x0003 is added to stack
	ADD R6,R6,#-1			
	STR R1,R6,#0			;x0001 is added to stack 

	;Push n number of disks to stack 
	LDR R0,R5,#0			;Loads n disks into R0
	ADD R6,R6,#-1			;Push R6 to stack - R6 contains n disks
	STR R0,R6,#0			;Storing contents of R0 (n) in next stack address
	JSR MOVEDISK			;jump to MoveDisk routine
	HALT		


;Callees portion of building the stack for the function call, moveDisk(n,1,3,2)
MOVEDISK
	;Push return address onto stack.
	ADD R6,R6,#-1			
	STR R7,R6,#0			;Store address in R7 (return address) in next stack address

	LDR R3,R6,#4			;R3 = midpost (address at r6 with offset of 4)
	LDR R2,R6,#3			;R2 = endpost
	LDR R1,R6,#2			;R1 = startpost
	LDR R0,R6,#1			;R0 = n

	ADD R0,R0,#-1           ;subtract 1 from n
	BRz PSOLSTEP            ;if we subtract 1 from R0 and get 0, we are at the base case of the recursive call
	ADD R0,R0,#1 			
		    			
;callers portion of MOVEDISK() activation record 
	ADD R6,R6,#-1			;Store midpost argument in stack
	STR R2,R6,#0			
	ADD R6,R6,#-1			;Store endpost argument in stack
	STR R3,R6,#0			
	ADD R6,R6,#-1			;Store startpost argument in stack
	STR R1,R6,#0			
	ADD R6,R6,#-1			;store n-1 in stack
	ADD R0,R0,#-1			
	STR R0,R6,#0			
	JSR MOVEDISK	        ;Jump to MOVE_DISK for callee portion of inductive step

	;String manipulation to print move disk n-1 from post a to post b 
	AND R0,R0,#0	        ;clear all registers to be used 	
	AND R1,R1,#0		
	AND R2,R2,#0
	AND R3,R3,#0
	LD R3,ASCII_OFFSET      ;load the ascii offset to r3
	
	LEA R1,STEP     	    ;load the address of the string to R1.
	ADD R6,R6,#1	        ;Get n-1 from stack
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add (n-1) + ascii offset
	ADD R2,R2,#10	        ;n is the 10th character in the string
	ADD R1,R1,R2            ;put (n-1) in the 10th spot in the string 
	STR R0,R1,#0            ;Store contents of R0 (ascii n-1) at address in R1
	
	ADD R6,R6,#1	        ;get the a post from the stack 
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add the ascii offset
    AND R2,R2,#0
    ADD R2,R2,#12	        
    ADD R1,R1,R2            ;Add 12 to get to the location of a
    STR R0,R1,#0            ;put a in the string
    
    ADD R6,R6,#1	        ;get the b post from the stack
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add the ascii offset
    AND R2,R2,#0            
    ADD R2,R2,#10	        ;add 10 to get to the location of b
    ADD R1,R1,R2            ;put b in the string
	STR R0,R1,#0
	LEA R0,STEP             ;put updated move prompt in R0
	PUTS                    ;print updated move prompt 

	ADD R6,R6,#-3	        ;reset the stack pointer to original position for continuity
	LDR R3,R6,#4	        ;R3 is midpost 
	LDR R2,R6,#3	        ;R2 = endpost
	LDR R1,R6,#2	        ;R1 = startpost
	LDR R0,R6,#1            ;R0 = n-1
			
	
;callers portion of activation record for MOVEDISK()
;this is the inductive step of the recursive call - the record is updated with the changed
;posts and the changed n. we switch start and mid because the disk is now being moved 
;from the midpost, not the start post 
	ADD R6,R6,#-1	
	STR R1,R6,#0	;push startpost to what was originally midpost slot in the stack
	
	ADD R6,R6,#-1	
	STR R2,R6,#0	;push endpost to the stack

	ADD R6,R6,#-1	
	STR R3,R6,#0	;push midpost to what was originally the startpost slot in the stack

	ADD R6,R6,#-1	
	ADD R0,R0,#-1	
	STR R0,R6,#0	;push n -1  to the stack 
	
	JSR MOVEDISK	;Return to move_disk for another recursive call
	LDR R7,R6,#0	;Load the return address back into r7 from the activation record
	ADD R6,R6,#1	;Pop return address off the stack 
	ADD R6,R6,#4	;Move back up 4 in the stack - the arguments that were in here will 
	                ;technically still be in the stack, but we are pointing to the bottom again. 
	RET		        ;Return to the return address in r7
	
;this is the base case - if we branch here, there is only one disk left on the start post 
PSOLSTEP
	;Reused code from the inductive step for string manipulation
	AND R0,R0,#0	        ;clear all registers to be used 	
	AND R1,R1,#0		
	AND R2,R2,#0
	AND R3,R3,#0
	LD R3,ASCII_OFFSET      ;load the ascii offset to r3
	
	LEA R1,STEP     	    ;load the address of the string to R1.
	ADD R6,R6,#1	        ;Get n-1 from stack
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add (n-1) + ascii offset
	ADD R2,R2,#10	        ;n is the 10th character in the string
	ADD R1,R1,R2            ;put (n-1) in the 10th spot in the string 
	STR R0,R1,#0            ;Store contents of R0 (ascii n-1) at address in R1
	
	ADD R6,R6,#1	        ;get the a post from the stack 
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add the ascii offset
    AND R2,R2,#0
    ADD R2,R2,#12	        
    ADD R1,R1,R2            ;Add 12 to get to the location of a
    STR R0,R1,#0            ;put a in the string
    
    ADD R6,R6,#1	        ;get the b post from the stack
	LDR R0,R6,#0            
	ADD R0,R0,R3            ;add the ascii offset
    AND R2,R2,#0            
    ADD R2,R2,#10	        ;add 10 to get to the location of b
    ADD R1,R1,R2            ;put b in the string
	STR R0,R1,#0
	LEA R0,STEP             ;put updated move prompt in R0
	PUTS                    ;print updated move prompt 
	ADD R6,R6,#-3	        ;Now because I added one for each string to R6 it messed up where R6 was pointing
			                ;at, so I have to make R6 point to the return address again. 
		
	LDR R7,R6,#0	        ;Loading what R6 is pointing to at this time which will be the return address into R7.
	ADD R6,R6,#1	        ;Pop off the RA and R6 is now pointing to diskNum slot in stack.
	ADD R6,R6,#4        	;Pop off arguments which makes R6 point to the RA from the previous activation record created.
	RET	      	            ;Return to whatever address is in R7.
	.END
		       	