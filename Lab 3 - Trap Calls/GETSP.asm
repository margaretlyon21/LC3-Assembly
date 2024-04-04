            .ORIG    x3000      ; Starts loading values at x3000
            LEA R0, PROMPT      ;Loads effective address of prompt label
            PUTS                ;Puts prompt characters to screen 
            AND R0,R0, #0       ;clears all registers to be used 
            AND R1, R1, #0
            AND R4, R4, #0
            AND R5,R5, #0
            LD R3, DATA        ;Loads starting address of place to store data into R3         

;Loop to get characters from input and put them in memory     
LOOP        GETC                ;gets character from input
            ADD R1, R0, #-10    ;Adds 10 to check is ASCII enter code
            BRz EXITLOOP        ;exits if enter 
            ADD R5, R0, #0      ;Puts first character into R5
            GETC
            ADD R4, R0, #0      ;Puts second character into R4
            ADD R4, R4, R4      ;Repetititve addition to shift second character to the left 8 bits
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R4, R4, R4      
            ADD R5, R5, R4      ;Add second character to first character in R5
            STR R5, R3, #0      ;Stores the new contents of R5 in the address held in R3 
            ADD R3,R3, #1       ;Adds a constant 1 to contents of R3
            BRnzp LOOP          ;Branches to beginning of loop
            
EXITLOOP    AND R0, R0, #0      ;Clears contents of R0
            LD  R0, DATA        ;Direct mode load of contents of address DATA into R0
            PUTSP               ;Puts ASCII characters starting from address in R0 to screen
            
            HALT
            
PROMPT      .Stringz "Enter String:\n";Stored ASCII data
DATA        .FILL x3100         ;Begin writing the inputted string at x3100

            .END 