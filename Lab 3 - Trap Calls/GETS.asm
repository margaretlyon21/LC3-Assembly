            .ORIG    x3000      ; Starts loading values at x3000
            LEA R0, PROMPT      ;Loads effective address of prompt label
            PUTS                ;Puts prompt characters to screen 
            AND R0,R0, #0       ;clears R0
            LD R3, DATA        ;Loads starting address of place to store data into R0         
            
LOOP        GETC                ;gets character from input
            ADD R1, R0, #-10    ;Adds 10 to check is ASCII enter code
            BRz EXITLOOP        ;exits if enter 
            STR R0, R3, #0      ;Stores the contents of R0 in the address held in R3 with 0 offset
            ADD R3,R3, #1       ;Adds a constant 1 to contents of R3
            BRnzp LOOP          ;Branches to beginning of loop
            
EXITLOOP    AND R0, R0, #0      ;Clears contents of R0
            LD  R0, DATA        ;Direct mode load od contents of address DATA into R0
            PUTS                ;Puts ASCII characters starting from address in R0 to screen
            
            HALT
            
PROMPT      .Stringz "Enter String:\n";Stored ASCII data
DATA        .FILL x3100         ;Begin writing the string entered at x3100

            .END