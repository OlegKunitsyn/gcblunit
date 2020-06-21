       >>SOURCE FORMAT FREE
*>**
*>  The KECCAK module, that uses the Keccak-f[1600] permutation.
*>
*>  @author Laszlo Erdos - https://www.facebook.com/wortfee
*>  @license LGPL-3.0
*>
*>  Date-Written: 2016-05-17
*>  Fields in LINKAGE SECTION:
*>    - LNK-KECCAK-RATE: The value of the rate r. The rate must be
*>      a multiple of 8 bits in this implementation.           
*>    - LNK-KECCAK-CAPACITY: The value of the capacity c. 
*>      The rate and capacity must have r+c=1600.       
*>    - LNK-KECCAK-INPUT: The input message.           
*>    - LNK-KECCAK-INPUT-BYTE-LEN: The number of input bytes provided
*>      in the input message.
*>    - LNK-KECCAK-DELIMITED-SUFFIX: Bits that will be automatically
*>      appended to the end of the input message, as in domain 
*>      separation.
*>    - LNK-KECCAK-OUTPUT: The buffer where to store the output.          
*>    - LNK-KECCAK-OUTPUT-BYTE-LEN: The number of output bytes desired.
*>
*>  This library is free software; you can redistribute it and/or
*>  modify it under the terms of the GNU Lesser General Public
*>  License as published by the Free Software Foundation; either
*>  version 3.0 of the License, or (at your option) any later version.
*>  
*>  This library is distributed in the hope that it will be useful,
*>  but WITHOUT ANY WARRANTY; without even the implied warranty of
*>  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*>  Lesser General Public License for more details.
*>  
*>  You should have received a copy of the GNU Lesser General Public
*>  License along with this library.
*>**

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KECCAK.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE                           PIC X(200).
 01 WS-RATE-IN-BYTES                   BINARY-LONG UNSIGNED.
 01 WS-BLOCK-SIZE                      BINARY-LONG UNSIGNED.
 01 WS-IND-1                           BINARY-LONG UNSIGNED. 
 01 WS-INPUT-BYTE-LEN                  BINARY-DOUBLE UNSIGNED.
 01 WS-INPUT-IND                       BINARY-DOUBLE UNSIGNED.
 01 WS-OUTPUT-BYTE-LEN                 BINARY-DOUBLE UNSIGNED.
 01 WS-OUTPUT-IND                      BINARY-DOUBLE UNSIGNED.
 01 WS-CHECK-PADDING-BIT               PIC X.
 
*> linkage for the STATE-PERMUTE module
 01 LNK-STATE-PERMUTE.
   02 LNK-STATE                        PIC X(200).
 
 LINKAGE SECTION.
 01 LNK-KECCAK-RATE                    BINARY-LONG UNSIGNED.
 01 LNK-KECCAK-CAPACITY                BINARY-LONG UNSIGNED.
 01 LNK-KECCAK-INPUT                   PIC X ANY LENGTH.
 01 LNK-KECCAK-INPUT-BYTE-LEN          BINARY-DOUBLE UNSIGNED.
 01 LNK-KECCAK-DELIMITED-SUFFIX        PIC X.
 01 LNK-KECCAK-OUTPUT                  PIC X ANY LENGTH.
 01 LNK-KECCAK-OUTPUT-BYTE-LEN         BINARY-DOUBLE UNSIGNED.
 
 PROCEDURE DIVISION USING LNK-KECCAK-RATE            
                          LNK-KECCAK-CAPACITY        
                          LNK-KECCAK-INPUT           
                          LNK-KECCAK-INPUT-BYTE-LEN  
                          LNK-KECCAK-DELIMITED-SUFFIX
                          LNK-KECCAK-OUTPUT          
                          LNK-KECCAK-OUTPUT-BYTE-LEN. 
 
*>------------------------------------------------------------------------------
 MAIN-KECCAK SECTION.
*>------------------------------------------------------------------------------

*>  Check rate and capacity, they must have r+c=1600
    IF (LNK-KECCAK-RATE + LNK-KECCAK-CAPACITY) NOT = 1600
    THEN
       GOBACK
    END-IF    

*>  Check rate, it must be a multiple of 8 bits in this implementation
    IF FUNCTION MOD(LNK-KECCAK-RATE, 8) NOT = ZEROES
    THEN
       GOBACK
    END-IF    

*>  Initialize fields    
    COMPUTE WS-RATE-IN-BYTES = LNK-KECCAK-RATE / 8 END-COMPUTE
    MOVE LNK-KECCAK-INPUT-BYTE-LEN  TO WS-INPUT-BYTE-LEN
    MOVE ZEROES                     TO WS-INPUT-IND
    MOVE LNK-KECCAK-OUTPUT-BYTE-LEN TO WS-OUTPUT-BYTE-LEN
    MOVE ZEROES                     TO WS-OUTPUT-IND
    MOVE ZEROES                     TO WS-BLOCK-SIZE
    
*>  Initialize the state
    MOVE ALL X"00" TO WS-STATE

*>  Absorb all the input blocks
    PERFORM UNTIL WS-INPUT-BYTE-LEN <= 0
       MOVE FUNCTION MIN(WS-INPUT-BYTE-LEN, WS-RATE-IN-BYTES) TO WS-BLOCK-SIZE
       
       PERFORM VARYING WS-IND-1 FROM 1 BY 1 UNTIL WS-IND-1 > WS-BLOCK-SIZE
          COMPUTE WS-INPUT-IND = WS-INPUT-IND + 1 END-COMPUTE
          
          CALL "CBL_XOR" USING LNK-KECCAK-INPUT(WS-INPUT-IND:1) 
                               WS-STATE(WS-IND-1:1)
                         BY VALUE 1
          END-CALL
       END-PERFORM

       COMPUTE WS-INPUT-BYTE-LEN = WS-INPUT-BYTE-LEN - WS-BLOCK-SIZE 
       END-COMPUTE
       
       IF WS-BLOCK-SIZE = WS-RATE-IN-BYTES
       THEN
          MOVE WS-STATE TO LNK-STATE OF LNK-STATE-PERMUTE
          CALL "STATE-PERMUTE" USING LNK-STATE-PERMUTE END-CALL
          MOVE LNK-STATE OF LNK-STATE-PERMUTE TO WS-STATE

          MOVE ZEROES TO WS-BLOCK-SIZE
       END-IF
    END-PERFORM

*>  Do the padding and switch to the squeezing phase.
*>  Absorb the last few bits and add the first bit of padding (which coincides
*>  with the delimiter in delimitedSuffix)
    CALL "CBL_XOR" USING LNK-KECCAK-DELIMITED-SUFFIX 
                         WS-STATE(WS-BLOCK-SIZE + 1:1)
                   BY VALUE 1
    END-CALL

*>  If the first bit of padding is at position rate - 1, we need a whole
*>  new block for the second bit of padding
    MOVE LNK-KECCAK-DELIMITED-SUFFIX TO WS-CHECK-PADDING-BIT
    CALL "CBL_XOR" USING X"80" 
                         WS-CHECK-PADDING-BIT
                   BY VALUE 1
    END-CALL

    IF  WS-CHECK-PADDING-BIT NOT = X"00"
    AND WS-BLOCK-SIZE = WS-RATE-IN-BYTES - 1
    THEN
       MOVE WS-STATE TO LNK-STATE OF LNK-STATE-PERMUTE
       CALL "STATE-PERMUTE" USING LNK-STATE-PERMUTE END-CALL
       MOVE LNK-STATE OF LNK-STATE-PERMUTE TO WS-STATE
    END-IF
    
*>  Add the second bit of padding
    CALL "CBL_XOR" USING X"80"
                         WS-STATE(WS-RATE-IN-BYTES:1)
                   BY VALUE 1
    END-CALL
    
*>  Switch to the squeezing phase
    MOVE WS-STATE TO LNK-STATE OF LNK-STATE-PERMUTE
    CALL "STATE-PERMUTE" USING LNK-STATE-PERMUTE END-CALL
    MOVE LNK-STATE OF LNK-STATE-PERMUTE TO WS-STATE
    
*>  Squeeze out all the output blocks
    MOVE 1 TO WS-OUTPUT-IND
    PERFORM UNTIL WS-OUTPUT-BYTE-LEN <= 0
       MOVE FUNCTION MIN(WS-OUTPUT-BYTE-LEN, WS-RATE-IN-BYTES) TO WS-BLOCK-SIZE

       MOVE WS-STATE(1:WS-BLOCK-SIZE) 
         TO LNK-KECCAK-OUTPUT(WS-OUTPUT-IND:WS-BLOCK-SIZE)
       COMPUTE WS-OUTPUT-IND = WS-OUTPUT-IND + WS-BLOCK-SIZE END-COMPUTE

       COMPUTE WS-OUTPUT-BYTE-LEN = WS-OUTPUT-BYTE-LEN - WS-BLOCK-SIZE 
       END-COMPUTE
       
       IF WS-OUTPUT-BYTE-LEN > 0
       THEN
          MOVE WS-STATE TO LNK-STATE OF LNK-STATE-PERMUTE
          CALL "STATE-PERMUTE" USING LNK-STATE-PERMUTE END-CALL
          MOVE LNK-STATE OF LNK-STATE-PERMUTE TO WS-STATE
       END-IF
    END-PERFORM
    
    GOBACK
    
    .
 MAIN-KECCAK-EX.
    EXIT.
 END PROGRAM KECCAK.
 
 
*>******************************************************************************
*> Module that computes the Keccak-f[1600] permutation on the given state.
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-PERMUTE.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROUND                           BINARY-LONG UNSIGNED.
 01 WS-X                               BINARY-LONG UNSIGNED.
 01 WS-Y                               BINARY-LONG UNSIGNED.
 01 WS-Y-TMP                           BINARY-LONG UNSIGNED.
 01 WS-J                               BINARY-LONG UNSIGNED.
 01 WS-T                               BINARY-LONG UNSIGNED.
 01 WS-R                               BINARY-LONG UNSIGNED.
 01 WS-BIT-POSITION                    BINARY-LONG UNSIGNED.

 01 LFSR-STATE                         PIC X.

 01 WS-C-TAB.
   02 WS-C                             PIC X(8) OCCURS 5.
 01 WS-D                               PIC X(8).
 01 WS-CURRENT                         PIC X(8).
 01 WS-TEMP                            PIC X(8).
 01 WS-TMP-TAB.
   02 WS-TMP                           PIC X(8) OCCURS 5.
 
 01 WS-LANE-0                          PIC X(8).
 01 WS-LANE-1                          PIC X(8).
 01 WS-LANE-2                          PIC X(8).
 01 WS-LANE-3                          PIC X(8).
 01 WS-LANE-4                          PIC X(8).

 01 WS-LANE-X                          PIC X(8).
 01 WS-LANE-NUM REDEFINES WS-LANE-X BINARY-DOUBLE UNSIGNED. 
 
 01 WS-IND-1                           BINARY-LONG. 
 01 WS-IND-2                           BINARY-LONG. 
 
*> linkage for the READ-LANE module
 01 LNK-READ-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).

*> linkage for the WRITE-LANE module
 01 LNK-WRITE-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).

*> linkage for the XOR-LANE module
 01 LNK-XOR-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).
   
*> linkage for the ROL-LANE module
 01 LNK-ROL-LANE.
   02 LNK-LANE                         PIC X(8).
   02 LNK-OFFSET                       BINARY-LONG UNSIGNED.

*> linkage for the LFSR86540 module
 01 LNK-LFSR86540.
   02 LNK-LFSR                         PIC X.
   02 LNK-RESULT                       BINARY-LONG.
   
 LINKAGE SECTION.
 01 LNK-STATE-PERMUTE.
   02 LNK-STATE                        PIC X(200).
 
 PROCEDURE DIVISION USING LNK-STATE-PERMUTE.

*>------------------------------------------------------------------------------
 MAIN-STATE-PERMUTE SECTION.
*>------------------------------------------------------------------------------
    
    MOVE X"01" TO LFSR-STATE
    
    PERFORM VARYING WS-ROUND FROM 0 BY 1 UNTIL WS-ROUND > 23

*>     Theta step (see [Keccak Reference, Section 2.3.2])
       PERFORM STEP-THETA
       
*>     Rho and pi steps (see [Keccak Reference, Sections 2.3.3 and 2.3.4])
       PERFORM STEP-RHO-AND-PI
       
*>     Chi step (see [Keccak Reference, Section 2.3.1])
       PERFORM STEP-CHI
       
*>     Iota step (see [Keccak Reference, Section 2.3.5])
       PERFORM STEP-IOTA
    END-PERFORM
    
    GOBACK
    
    .
 MAIN-STATE-PERMUTE-EX.
    EXIT.
    
*>------------------------------------------------------------------------------
 STEP-THETA SECTION.
*>------------------------------------------------------------------------------

    INITIALIZE WS-C-TAB
    INITIALIZE WS-D
    
*>  Compute the parity of the columns
    PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
       PERFORM READ-LANES
       PERFORM XOR-LANES
       MOVE WS-LANE-4 TO WS-C(WS-X + 1)
    END-PERFORM
    
    PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
*>     Compute the theta effect for a given column
       COMPUTE WS-IND-1 = 1 + FUNCTION MOD(WS-X + 4, 5) END-COMPUTE
       MOVE WS-C(WS-IND-1) TO WS-LANE-0
    
       COMPUTE WS-IND-1 = 1 + FUNCTION MOD(WS-X + 1, 5) END-COMPUTE
       MOVE WS-C(WS-IND-1) TO LNK-LANE   OF LNK-ROL-LANE
       MOVE 1              TO LNK-OFFSET OF LNK-ROL-LANE
       CALL "ROL-LANE" USING LNK-ROL-LANE END-CALL
       MOVE LNK-LANE OF LNK-ROL-LANE TO WS-LANE-1
       
       CALL "CBL_XOR" USING WS-LANE-0 WS-LANE-1
                      BY VALUE 8
       END-CALL
       
       MOVE WS-LANE-1 TO WS-D                    
       
*>     Add the theta effect to the whole column   
       PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 4
          MOVE WS-X 
            TO LNK-X     OF LNK-XOR-LANE
          MOVE WS-Y 
            TO LNK-Y     OF LNK-XOR-LANE
          MOVE LNK-STATE OF LNK-STATE-PERMUTE 
            TO LNK-STATE OF LNK-XOR-LANE
          MOVE WS-D 
            TO LNK-LANE  OF LNK-XOR-LANE
          CALL "XOR-LANE" USING LNK-XOR-LANE END-CALL
          MOVE LNK-STATE OF LNK-XOR-LANE
            TO LNK-STATE OF LNK-STATE-PERMUTE
       END-PERFORM
    END-PERFORM
      
    .
 STEP-THETA-EX.
    EXIT.
    
*>------------------------------------------------------------------------------
 READ-LANES SECTION.
*>------------------------------------------------------------------------------

    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE 0 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-LANE-0

    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE 1 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-LANE-1

    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE 2 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-LANE-2
      
    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE 3 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-LANE-3
      
    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE 4 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-LANE-4
    
    .
 READ-LANES-EX.
    EXIT.
    
*>------------------------------------------------------------------------------
 XOR-LANES SECTION.
*>------------------------------------------------------------------------------

    CALL "CBL_XOR" USING WS-LANE-0 WS-LANE-1
                   BY VALUE 8
    END-CALL
    
    CALL "CBL_XOR" USING WS-LANE-1 WS-LANE-2
                   BY VALUE 8
    END-CALL
    
    CALL "CBL_XOR" USING WS-LANE-2 WS-LANE-3
                   BY VALUE 8
    END-CALL
    
    CALL "CBL_XOR" USING WS-LANE-3 WS-LANE-4
                   BY VALUE 8
    END-CALL
      
    .
 XOR-LANES-EX.
    EXIT.
    
*>------------------------------------------------------------------------------
 STEP-RHO-AND-PI SECTION.
*>------------------------------------------------------------------------------

    INITIALIZE WS-CURRENT
    INITIALIZE WS-TEMP
        
*>  Start at coordinates (1 0)
    MOVE 1 TO WS-X
    MOVE 0 TO WS-Y
        
    MOVE WS-X 
      TO LNK-X     OF LNK-READ-LANE
    MOVE WS-Y 
      TO LNK-Y     OF LNK-READ-LANE
    MOVE LNK-STATE OF LNK-STATE-PERMUTE 
      TO LNK-STATE OF LNK-READ-LANE
    CALL "READ-LANE" USING LNK-READ-LANE END-CALL
    MOVE LNK-LANE  OF LNK-READ-LANE
      TO WS-CURRENT

*>  Iterate over ((0 1)(2 3))^t * (1 0) for 0 = t = 23
    PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 23
*>     Compute the rotation constant r = (t+1)(t+2)/2
       COMPUTE WS-R = FUNCTION MOD(((WS-T + 1) * (WS-T + 2) / 2), 64)
       END-COMPUTE
       
*>     Compute ((0 1)(2 3)) * (x y)
       COMPUTE WS-Y-TMP = FUNCTION MOD((2 * WS-X + 3 * WS-Y), 5)
       END-COMPUTE
       MOVE WS-Y     TO WS-X
       MOVE WS-Y-TMP TO WS-Y
       
*>     Swap current and state(x,y), and rotate
       MOVE WS-X 
         TO LNK-X     OF LNK-READ-LANE
       MOVE WS-Y 
         TO LNK-Y     OF LNK-READ-LANE
       MOVE LNK-STATE OF LNK-STATE-PERMUTE 
         TO LNK-STATE OF LNK-READ-LANE
       CALL "READ-LANE" USING LNK-READ-LANE END-CALL
       MOVE LNK-LANE  OF LNK-READ-LANE
         TO WS-TEMP
         
       MOVE WS-CURRENT TO LNK-LANE   OF LNK-ROL-LANE
       MOVE WS-R       TO LNK-OFFSET OF LNK-ROL-LANE
       CALL "ROL-LANE" USING LNK-ROL-LANE END-CALL
       MOVE LNK-LANE OF LNK-ROL-LANE TO WS-LANE-0
       
       MOVE WS-X 
         TO LNK-X     OF LNK-WRITE-LANE
       MOVE WS-Y 
         TO LNK-Y     OF LNK-WRITE-LANE
       MOVE LNK-STATE OF LNK-STATE-PERMUTE 
         TO LNK-STATE OF LNK-WRITE-LANE
       MOVE WS-LANE-0 
         TO LNK-LANE  OF LNK-WRITE-LANE
       CALL "WRITE-LANE" USING LNK-WRITE-LANE END-CALL
       MOVE LNK-STATE OF LNK-WRITE-LANE
         TO LNK-STATE OF LNK-STATE-PERMUTE
       
       MOVE WS-TEMP TO WS-CURRENT
    END-PERFORM
      
    .
 STEP-RHO-AND-PI-EX.
    EXIT.

*>------------------------------------------------------------------------------
 STEP-CHI SECTION.
*>------------------------------------------------------------------------------

    INITIALIZE WS-TMP-TAB

    PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 4
*>     Take a copy of the plane
       PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
          MOVE WS-X 
            TO LNK-X     OF LNK-READ-LANE
          MOVE WS-Y 
            TO LNK-Y     OF LNK-READ-LANE
          MOVE LNK-STATE OF LNK-STATE-PERMUTE 
            TO LNK-STATE OF LNK-READ-LANE
          CALL "READ-LANE" USING LNK-READ-LANE END-CALL
          MOVE LNK-LANE  OF LNK-READ-LANE
            TO WS-TMP(WS-X + 1)
       END-PERFORM
       
*>     Compute chi on the plane       
       PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
          MOVE WS-TMP(WS-X + 1) TO WS-LANE-0

          COMPUTE WS-IND-1 = 1 + FUNCTION MOD(WS-X + 1, 5) END-COMPUTE
          MOVE WS-TMP(WS-IND-1) TO WS-LANE-1

          CALL "CBL_NOT" USING WS-LANE-1
                         BY VALUE 8
          END-CALL
          
          COMPUTE WS-IND-1 = 1 + FUNCTION MOD(WS-X + 2, 5) END-COMPUTE
          MOVE WS-TMP(WS-IND-1) TO WS-LANE-2
       
          CALL "CBL_AND" USING WS-LANE-1 WS-LANE-2
                         BY VALUE 8
          END-CALL

          CALL "CBL_XOR" USING WS-LANE-0 WS-LANE-2
                         BY VALUE 8
          END-CALL
       
          MOVE WS-X 
            TO LNK-X     OF LNK-WRITE-LANE
          MOVE WS-Y 
            TO LNK-Y     OF LNK-WRITE-LANE
          MOVE LNK-STATE OF LNK-STATE-PERMUTE 
            TO LNK-STATE OF LNK-WRITE-LANE
          MOVE WS-LANE-2 
            TO LNK-LANE  OF LNK-WRITE-LANE
          CALL "WRITE-LANE" USING LNK-WRITE-LANE END-CALL
          MOVE LNK-STATE OF LNK-WRITE-LANE
            TO LNK-STATE OF LNK-STATE-PERMUTE
       END-PERFORM
    END-PERFORM

    .
 STEP-CHI-EX.
    EXIT.

*>------------------------------------------------------------------------------
 STEP-IOTA SECTION.
*>------------------------------------------------------------------------------

    PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 6
*>     2^j-1
       COMPUTE WS-BIT-POSITION = (2 ** WS-J) - 1 END-COMPUTE

       INITIALIZE LNK-LFSR86540
       MOVE LFSR-STATE 
         TO LNK-LFSR  OF LNK-LFSR86540
       CALL "LFSR86540" USING LNK-LFSR86540 END-CALL
*>     save new LFSR-STATE
       MOVE LNK-LFSR OF LNK-LFSR86540
         TO LFSR-STATE
       
       IF LNK-RESULT OF LNK-LFSR86540 NOT = ZEROES
       THEN
          COMPUTE WS-LANE-NUM = 2 ** WS-BIT-POSITION END-COMPUTE
          
          MOVE 0 
            TO LNK-X     OF LNK-XOR-LANE
          MOVE 0 
            TO LNK-Y     OF LNK-XOR-LANE
          MOVE LNK-STATE OF LNK-STATE-PERMUTE 
            TO LNK-STATE OF LNK-XOR-LANE
          MOVE WS-LANE-X
            TO LNK-LANE  OF LNK-XOR-LANE
          CALL "XOR-LANE" USING LNK-XOR-LANE END-CALL
          MOVE LNK-STATE OF LNK-XOR-LANE
            TO LNK-STATE OF LNK-STATE-PERMUTE
       END-IF
    END-PERFORM

    .
 STEP-IOTA-EX.
    EXIT.
    
 END PROGRAM STATE-PERMUTE.

 
*>******************************************************************************
*> Module to load a 64-bit value from STATE.
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. READ-LANE.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IND                             BINARY-LONG.
 
 LINKAGE SECTION.
 01 LNK-READ-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).
 
 PROCEDURE DIVISION USING LNK-READ-LANE.

*>------------------------------------------------------------------------------
 MAIN-READ-LANE SECTION.
*>------------------------------------------------------------------------------

    COMPUTE WS-IND = (LNK-X + 5 * LNK-Y) * 8 + 1 END-COMPUTE
    
    MOVE LNK-STATE(WS-IND:8) TO LNK-LANE
    
    GOBACK
    
    .
 MAIN-READ-LANE-EX.
    EXIT.
 END PROGRAM READ-LANE.

 
*>******************************************************************************
*> Module to write a 64-bit value in STATE.
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WRITE-LANE.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IND                             BINARY-LONG.
 
 LINKAGE SECTION.
 01 LNK-WRITE-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).
 
 PROCEDURE DIVISION USING LNK-WRITE-LANE.

*>------------------------------------------------------------------------------
 MAIN-WRITE-LANE SECTION.
*>------------------------------------------------------------------------------

    COMPUTE WS-IND = (LNK-X + 5 * LNK-Y) * 8 + 1 END-COMPUTE
    
    MOVE LNK-LANE TO LNK-STATE(WS-IND:8)
    
    GOBACK
    
    .
 MAIN-WRITE-LANE-EX.
    EXIT.
 END PROGRAM WRITE-LANE.

 
*>******************************************************************************
*> Module to xor and write a 64-bit value in STATE.
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. XOR-LANE.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IND                             BINARY-LONG.
 01 WS-LANE-1                          PIC X(8).
 01 WS-LANE-2                          PIC X(8).
 
 LINKAGE SECTION.
 01 LNK-XOR-LANE.
   02 LNK-X                            BINARY-LONG UNSIGNED.
   02 LNK-Y                            BINARY-LONG UNSIGNED.
   02 LNK-STATE                        PIC X(200).
   02 LNK-LANE                         PIC X(8).
 
 PROCEDURE DIVISION USING LNK-XOR-LANE.

*>------------------------------------------------------------------------------
 MAIN-XOR-LANE SECTION.
*>------------------------------------------------------------------------------

    MOVE LNK-LANE TO WS-LANE-1

    COMPUTE WS-IND = (LNK-X + 5 * LNK-Y) * 8 + 1 END-COMPUTE
    MOVE LNK-STATE(WS-IND:8) TO WS-LANE-2
    
    CALL "CBL_XOR" USING WS-LANE-1 WS-LANE-2
                   BY VALUE 8
    END-CALL
    
    MOVE WS-LANE-2 TO LNK-STATE(WS-IND:8)
    
    GOBACK
    
    .
 MAIN-XOR-LANE-EX.
    EXIT.
 END PROGRAM XOR-LANE.
 
 
*>******************************************************************************
*> Module to rotate a 64-bit value.
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROL-LANE.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IND                             BINARY-LONG.
 01 WS-LANE-X-1                        PIC X(8).
 01 WS-LANE-9-1 REDEFINES WS-LANE-X-1  BINARY-DOUBLE UNSIGNED. 
 01 WS-LANE-X-2                        PIC X(8).
 01 WS-LANE-9-2 REDEFINES WS-LANE-X-2  BINARY-DOUBLE UNSIGNED. 
 
 LINKAGE SECTION.
 01 LNK-ROL-LANE.
   02 LNK-LANE                         PIC X(8).
   02 LNK-OFFSET                       BINARY-LONG UNSIGNED.
 
 PROCEDURE DIVISION USING LNK-ROL-LANE.

*>------------------------------------------------------------------------------
 MAIN-ROL-LANE SECTION.
*>------------------------------------------------------------------------------

    IF LNK-OFFSET = ZEROES
    THEN
*>     nothing to do
       GOBACK
    END-IF

    MOVE LNK-LANE TO WS-LANE-X-1
    MOVE LNK-LANE TO WS-LANE-X-2

    PERFORM VARYING WS-IND FROM 1 BY 1 UNTIL WS-IND > LNK-OFFSET
       COMPUTE WS-LANE-9-1 = WS-LANE-9-1 * 2 END-COMPUTE
    END-PERFORM

    PERFORM VARYING WS-IND FROM 1 BY 1 UNTIL WS-IND > (64 - LNK-OFFSET)
       COMPUTE WS-LANE-9-2 = WS-LANE-9-2 / 2 END-COMPUTE
    END-PERFORM
    
    CALL "CBL_XOR" USING WS-LANE-X-1 WS-LANE-X-2
                   BY VALUE 8
    END-CALL
    
    MOVE WS-LANE-X-2 TO LNK-LANE
    
    GOBACK
    
    .
 MAIN-ROL-LANE-EX.
    EXIT.
 END PROGRAM ROL-LANE.

 
*>******************************************************************************
*> Module that computes the linear feedback shift register (LFSR) used to
*> define the round constants (see [Keccak Reference, Section 1.2]).
*>******************************************************************************
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LFSR86540.

 ENVIRONMENT DIVISION.

 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LFSR-CHECK                      PIC X.
 01 WS-LFSR-WORK                       PIC X.
 01 WS-LFSR-WORK-BIN REDEFINES WS-LFSR-WORK BINARY-CHAR UNSIGNED.
 
 LINKAGE SECTION.
 01 LNK-LFSR86540.
   02 LNK-LFSR                         PIC X.
   02 LNK-RESULT                       BINARY-LONG.
 
 PROCEDURE DIVISION USING LNK-LFSR86540.

*>------------------------------------------------------------------------------
 MAIN-LFSR86540 SECTION.
*>------------------------------------------------------------------------------
    
    MOVE LNK-LFSR TO WS-LFSR-CHECK
    MOVE LNK-LFSR TO WS-LFSR-WORK

    CALL "CBL_AND" USING X"01" WS-LFSR-CHECK
                   BY VALUE 1
    END-CALL               
    
    IF WS-LFSR-CHECK NOT = X"00"
    THEN
       MOVE 1 TO LNK-RESULT
    ELSE
       MOVE 0 TO LNK-RESULT
    END-IF

    MOVE LNK-LFSR TO WS-LFSR-CHECK

    CALL "CBL_AND" USING X"80" WS-LFSR-CHECK
                   BY VALUE 1
    END-CALL               
    
    IF WS-LFSR-CHECK NOT = X"00"
    THEN
*>     Primitive polynomial over GF(2): x^8+x^6+x^5+x^4+1       
       COMPUTE WS-LFSR-WORK-BIN = WS-LFSR-WORK-BIN * 2 END-COMPUTE
       CALL "CBL_XOR" USING X"71" WS-LFSR-WORK-BIN
                      BY VALUE 1
       END-CALL               
    ELSE
       COMPUTE WS-LFSR-WORK-BIN = WS-LFSR-WORK-BIN * 2 END-COMPUTE
    END-IF

    MOVE WS-LFSR-WORK TO LNK-LFSR
    
    GOBACK
    
    .
 MAIN-LFSR86540-EX.
    EXIT.
 END PROGRAM LFSR86540.
