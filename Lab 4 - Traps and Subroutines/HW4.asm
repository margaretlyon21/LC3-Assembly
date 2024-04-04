;memory dump
            .ORIG       x3000
MEMLOOP     LEA         R0, STRING1          ; Load the address of the beginning of a string into R0
            TRAP        x22                 ; "call PUTS"
            LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            LEA         R0, HEX_X           ; load the address of the x
            TRAP        x22                 ; call PUTS
            TRAP        x40                 ; call INPUT
            ST          R0, STARTING
            
            LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            LEA         R0, STRING2          ; Load the address of the beginning of a string into R0
            TRAP        x22                 ; "call PUTS"
            LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            LEA         R0, HEX_X           ; load the address of the x
            TRAP        x22                 ; call PUTS
            TRAP        x40                 ; call INPUT
            ST          R0, ENDING
            
            LD          R1, STARTING        ; load starting and ending
            LD          R2, ENDING
            NOT         R1, R1              ; Negates the starting address
            ADD         R2, R2, R1          ; R2 = ending - starting
            BRn         WRONG
            
            NOT         R2, R2              ;negates range so we can use it to know when to stop
            LD          R1, STARTING          ;bc we need to print the memory locations
            AND         R3, R3, #0          ;clears r3 to be used as counter
            
            LD         R0, NEWLINE
            OUT
            LEA         R0, CONTENTS
            TRAP x22
            
OUTPUTLOOP  LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            AND         R0, R0, #0          ;clears r0
            ADD         R0, R1, R3          ;Adds the loop counter to the end to get current location
            TRAP        x41                 ;output trap to output memory location
            LEA         R0, SPACE
            TRAP x22
            AND         R0, R0, #0          ;clears r0
            ADD         R0, R1, R3          ;Adds the loop counter to the end to get current location
            LDR         R0, R0, #0
            TRAP        x41
            ADD         R3, R3, #1
            ADD         R2, R2, #1         ;loop counter
            BRp         EXIT
            BR          OUTPUTLOOP
            
EXIT        HALT

WRONG       LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            LEA          R0, WRONGMESS
            TRAP x22
            LD          R0, NEWLINE         ; load the ASCII code for newline into R0
            OUT                             ; print the ASCII char in R0 to screen (\n)
            BRnzp       MEMLOOP

SPACE       .STRINGZ    " "
STRING1     .STRINGZ    "Enter Starting Memory Address: "
HEX_X       .STRINGZ    "x"
STRING2     .STRINGZ    "Enter Ending Memory Address: "
CONTENTS    .STRINGZ    "Memory Contents:"            
WRONGMESS   .STRINGZ    "Starting address must be before ending address!" 
NEWLINE     .FILL       xA
STARTING    .FILL       x1     
ENDING      .FILL       x2
            .END

;__________________________________________________________________
;input routine
            .ORIG       x4000 
            SHIFT48     .FILL       #48   
            SHIFT70     .FILL       #70
            SHIFT57     .FILL       #57
            SHIFT65     .FILL       #65
            ALPHA       .FILL       #55

INPUT       ADD         R6, R6, #-1     ;push registers to stack    
            STR         R1, R6, #0   
            ADD         R6, R6, #-1         
            STR         R2, R6, #0  
            ADD         R6, R6, #-1         
            STR         R3, R6, #0  
            ADD         R6, R6, #-1         
            STR         R4, R6, #0 
            
            AND         R0, R0, #0          ;clear registers
            AND         R1, R1, #0
            AND         R2, R2, #0
            AND         R3, R3, #0
            AND         R4, R4, #0

            ;get character loop             
LOOP        ADD         R2, R2, #-4         
            BRzp        EXITLOOP            ;if loop has already hapened 4 times, stop
            ADD         R2, R2, #4
            ADD         R2, R2, #1          ; R2 is the loop counter
            
            GETC                            ; Gets the character from input
            PUTC
            
            LD          R1, SHIFT48         ;If <48, Error
            NOT         R1,R1               ; negates the shift
            AND         R4, R4, #0
            ADD         R4, R0, R1          ; subtracts 48
            ADD         R4, R4, #1
            BRn ERROR                       
            
            LD          R1, SHIFT70         ;if >70, Error
            NOT         R1,R1               ; negates the shift
            AND         R4, R4, #0
            ADD         R4, R0, R1          ; subtracts 70
            ADD         R4, R4, #1
            BRp ERROR                       
            
            
            LD          R1, SHIFT57         ;if >58, number
            NOT         R1,R1               ; negates the shift
            AND         R4, R4, #0
            ADD         R4, R0, R1          ; subtracts 58
            ADD         R4, R4, #1
            BRnz NUMBER           
            
            LD          R1, SHIFT65         ;if >65, letter
            NOT         R1,R1               ; negates the shift
            AND         R4, R4, #0
            ADD         R4, R0, R1          ; subtracts 58
            ADD         R4, R4, #1
            BRzp LETTER
            BR  ERROR

NUMBER      LD          R1, SHIFT48         ;Subtract 48 to get decimal number
            NOT         R1,R1               
            AND         R4, R4, #0
            ADD         R4, R0, R1          ;R4 contains decimal number 0-9
            ADD         R4, R4, #1
            BRnzp       PROCESS

LETTER      LD          R1, ALPHA          ;Subtract 55 to get a number that translates to the hex for A-F
            NOT         R1,R1               
            AND         R4, R4, #0
            ADD         R4, R0, R1          ;R4 contains decimal number 10-15
            ADD         R4, R4, #1
            BRnzp       PROCESS

PROCESS     ADD R3, R3, R3                  ; Shift contents over 4 bits
            ADD R3, R3, R3  
            ADD R3, R3, R3
            ADD R3, R3, R3
            ADD R3, R3, R4                  ; Puts hex digit into lower 4 bits of R3
            BRnzp LOOP

ERROR       AND         R0,R0, #0
ERMESSAGE   .STRINGZ    "Invalid Hex input, try again"
            LEA         R0, ERMESSAGE
            TRAP x22
            RTI                             ; return from interupt will switch r6 back to user mode 
            
EXITLOOP    AND R0, R0, #0
            ADD R0, R3, R0
 
            LDR R4, R6, #0          ;pop registers back from stack
            ADD R6, R6, #1
            LDR R3, R6, #0          
            ADD R6, R6, #1
            LDR R2, R6, #0          
            ADD R6, R6, #1
            LDR R1, R6, #0          
            ADD R6, R6, #1
            RTI         
            .END

;________________________________________________________________________________            
;output trap implementation
            .ORIG       x5000
            PRINTX              .STRINGZ "x"
            NUMBERSHIFT          .FILL #48 
            LETTERSHIFT          .FILL #55 
            FIRSTCHAR           .FILL   x1
            SECONDCHAR          .FILL   x2
            THIRDCHAR           .FILL   x3
            FOURTHCHAR          .FILL   x4
            MASK                .FILL   xF
            
OUTPUT      ADD         R6, R6, #-1     ;push registers to stack    
            STR         R1, R6, #0   
            ADD         R6, R6, #-1         
            STR         R2, R6, #0  
            ADD         R6, R6, #-1         
            STR         R3, R6, #0  
            ADD         R6, R6, #-1         
            STR         R4, R6, #0 
            
            AND         R1, R1, #0  ;clears registers
            AND         R2, R2, #0  
            AND         R3, R3, #0
            AND         R4, R4, #0
            LD  R3, MASK            ;loads the mask in r3
            ADD R1, R0, #0          ;stores original pattern in r1
            
            AND R0, R0, R3          ;applies the mask to the hex in r0
            ST  R0, FOURTHCHAR      ;gets the last character
            AND R0, R1, R1          ;puts original string back to R0
            TRAP x42                ;shifts the string over 4 bits
            TRAP x42
            TRAP x42
            TRAP x42
            AND R1, R0, R0          ;R1 now has 12 bit string
            AND R0, R0, R3          ;applies mask to string
            ST R0, THIRDCHAR
            ADD R0, R1, #0          ;R0 has 12 bit string
            TRAP x42                ;move the string over 4 more bits
            TRAP x42
            TRAP x42
            TRAP x42
            AND R1, R0, R0          ;R1 now has 8 bit string
            AND R0, R0, R3          ;applies mask to string
            ST R0, SECONDCHAR
            ADD, R0, R1, #0         
            TRAP x42
            TRAP x42
            TRAP x42
            TRAP x42
            ST R0, FIRSTCHAR;       ;4 bit string
            
            ADD R2, R2, #-3           ;r2 will be the loop counter
            LEA R4, FIRSTCHAR       ;loads the address of the first character to r4
            LD  R0, PRINTX          ;prints the x
            OUT

OUTLOOP     LDR R0, R4, #0          ;Loads the value at the memory location in r4 to r0
            AND R1, R1, #0
            ADD R1, R0, #-9          ;Adds the number/letter offset and the value in r0
            BRp ISLETTER            ;if positive, it is a letter
            BRnz ISNUMBER           ;if zero or negative, its a number
            
ISLETTER    LD R1, LETTERSHIFT      ;loads the letter offset into r1
            ADD R0, R0, R1          ;adds the value and the offset into r0  
            OUT
            ADD R4, R4, #1          ;incrememnt the pointer
            ADD R2, R2, #1          ;add to the loop counter
            BRp LOOPDONE
            BRnz OUTLOOP


ISNUMBER    LD  R1, NUMBERSHIFT     ;loads the number offset into r1
            ADD R0, R0, R1          ;adds the value and the offset into r0
            OUT
            ADD R4, R4, #1          ;incrememnts the pointer
            ADD R2, R2, #1          ;adds to the loop counter
            BRp LOOPDONE
            BRnz OUTLOOP


LOOPDONE    LDR R4, R6, #0          ;pop registers back from stack
            ADD R6, R6, #1
            LDR R3, R6, #0          
            ADD R6, R6, #1
            LDR R2, R6, #0          
            ADD R6, R6, #1
            LDR R1, R6, #0          
            ADD R6, R6, #1
            RTI  
            
HEX         .STRINGZ "x"
            .END
;________________________________________________________________________________
;Right Shift - Trap x42
           .ORIG    x6000
            ; back up all the registers by pushing them on the system stack
            ADD     R6, R6, #-1
            STR     R1, R6, #0
            ADD     R6, R6, #-1
            STR     R2, R6, #0
            ADD     R6, R6, #-1
            STR     R3, R6, #0
            ADD     R6, R6, #-1
            STR     R4, R6, #0
            ADD     R6, R6, #-1
            STR     R5, R6, #0
            
            ; move R0 into R3.  We'll keep the copy of the 
            ; unshifted value in R3 as R0 gets used for all kinds
            ; of scratch stuff and/or sending parameters to other
            ; traps
            
            AND     R3, R3, #0
            ADD     R3, R3, R0
   
            LD      R1, MASK_TEST
            LD      R5, MASK_WRITE
            AND     R4, R4, #0       ; I'm going to assembble the answer in R4.
                                     ; it should be cleared initally 
                                     
            
            LD      R2, LOOP_COUNT
LOOP2        AND     R0, R3, R1
            BRz     ELSE
            JSR     P1
            BRnzp   CONTINUE
ELSE        JSR     P0
CONTINUE    ADD     R1, R1, R1
            ADD     R5, R5, R5
            ADD     R2, R2, #-1
            BRnp     LOOP2

            ; I'm done.  Copy the created answer into R0 so it can be
            ; "returned" to the caller.  Restore all the other registers
            ; from the system stack and then return from TRAP call
DONE        AND     R0, R0, #0
            ADD     R0, R0, R4
            LDR     R5, R6, #0
            ADD     R6, R6, #1
            LDR     R4, R6, #0
            ADD     R6, R6, #1
            LDR     R3, R6, #0
            ADD     R6, R6, #1
            LDR     R2, R6, #0
            ADD     R6, R6, #1
            LDR     R1, R6, #0
            ADD     R6, R6, #1
            RTI

P0          ; debug code LD      R0, ASCII_0
            ; debug code OUT     
            RET

P1          ; debug code LD      R0, ASCII_1
            ; debug code OUT
            ADD     R4, R4, R5
            RET
            
ASCII_0     .FILL   #48
ASCII_1     .FILL   #49
MASK_TEST   .FILL   x0002
MASK_WRITE  .FILL   x0001
LOOP_COUNT  .FILL   xF
            .END
        
;________________________________________________________________________________
;trap vector table
            .ORIG       x40
            .FILL       INPUT
            .END
            
            .ORIG       x41
            .FILL       OUTPUT
            .END
            
            .ORIG   x42
            .FILL   x6000
            .END
