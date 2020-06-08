       >>SOURCE FORMAT FREE
*>**
*>  Core library: string
*>
*>  @author Olegs Kunicins
*>  @license LGPL-3.0
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

*>*
*> Find the position of the first occurrence of a substring in a string.
*> Case-sensitive.
*> 
*> @param l-haystack String to search in
*> @param l-needle String to search for
*> @return Position where the needle exists relative to the beginnning
*> of l-haystack. Returns 0 if not found.
*>*
identification division.
function-id. substr-pos.
environment division.
configuration section.
repository. function length intrinsic.
data division.
working-storage section.
    01 haystack-idx usage index value 1.
    01 needle-idx usage index value 1.
linkage section.
    01 l-haystack pic x any length.
    01 l-needle pic x any length.
    01 l-result usage binary-long unsigned value 0.
procedure division using l-haystack, l-needle returning l-result.
    initialize haystack-idx, needle-idx, l-result all to value.
    if length(l-haystack) < length(l-needle)
        goback
    end-if.
    perform until haystack-idx > length(l-haystack)
        if l-haystack(haystack-idx:1) = l-needle(needle-idx:1)
           if needle-idx = length(l-needle)
               compute l-result = haystack-idx - needle-idx + 1
               exit perform
           end-if
           set needle-idx up by 1
        else
           initialize needle-idx all to value
        end-if
        set haystack-idx up by 1
    end-perform.
end function substr-pos.


*>*
*> Find the position of the first occurrence of a substring in a string.
*> Case-insensitive.
*> 
*> @param l-haystack String to search in
*> @param l-needle String to search for
*> @return Position where the needle exists relative to the beginnning
*> of l-haystack. Returns 0 if not found.
*>*
identification division.
function-id. substr-ipos.
environment division.
configuration section.
repository. 
    function lower-case intrinsic
    function substr-pos.
data division.
working-storage section.
linkage section.
    01 l-haystack pic x any length.
    01 l-needle pic x any length.
    01 l-result usage binary-long unsigned value 0.
procedure division using l-haystack, l-needle returning l-result.
    move substr-pos(lower-case(l-haystack), lower-case(l-needle)) to l-result.
end function substr-ipos.

*>*
*> Convert one byte into hexadecimal representation.
*> 
*> @param l-byte Byte
*> @return 2 hexadecimal chars
*>*
identification division.
function-id. byte-to-hex.
environment division.
configuration section.
data division.
working-storage section.
    01 CHARS pic x(16) value "0123456789ABCDEF".
    01 ws-remainder binary-char unsigned.
    01 ws-quotient binary-char unsigned.
linkage section.
    01 l-byte usage binary-char unsigned.
    01 l-hex pic x(2).
procedure division using l-byte returning l-hex.
    divide l-byte by 16 giving ws-quotient remainder ws-remainder.
    add 1 to ws-remainder.
    add 1 to ws-quotient.
    move CHARS(ws-remainder:1) to l-hex(2:1).
    move CHARS(ws-quotient:1) to l-hex(1:1).
end function byte-to-hex.

*>*
*> Convert one byte into hexadecimal representation.
*> 
*> @param l-hex 2 hexadecimal chars
*> @return Byte
*>*
identification division.
function-id. hex-to-byte.
environment division.
configuration section.
repository. 
    function ord upper-case intrinsic.
data division.
working-storage section.
    01 ws-remainder usage binary-char unsigned.
    01 ws-quotient usage binary-char unsigned.
linkage section.
    01 l-hex pic x(2).
    01 l-byte usage binary-char unsigned.
procedure division using l-hex returning l-byte.
    compute ws-quotient = ord(upper-case(l-hex(1:1))) - 49.
    if ws-quotient > 16
        subtract 7 from ws-quotient
    end-if.
    compute ws-remainder = ord(upper-case(l-hex(2:1))) - 49.
    if ws-remainder > 16
        subtract 7 from ws-remainder
    end-if.
    compute l-byte = ws-quotient * 16 + ws-remainder.
end function hex-to-byte.

*>*
*> Count the number of substring occurrences. Case-sensitive.
*> 
*> @param l-haystack String to search in
*> @param l-needle String to search for
*> @return
*>*
identification division.
function-id. substr-count.
environment division.
configuration section.
repository. function length intrinsic.
data division.
working-storage section.
    01 haystack-idx usage index value 1.
    01 needle-idx usage index value 1.
linkage section.
    01 l-haystack pic x any length.
    01 l-needle pic x any length.
    01 l-result usage binary-long unsigned value 0.
procedure division using l-haystack, l-needle returning l-result.
    initialize haystack-idx, needle-idx, l-result all to value.
    if length(l-haystack) < length(l-needle)
        goback
    end-if.
    perform until haystack-idx > length(l-haystack)
        if l-haystack(haystack-idx:1) = l-needle(needle-idx:1)
           if needle-idx = length(l-needle)
               add 1 to l-result
           end-if
           set needle-idx up by 1
        else
           initialize needle-idx all to value
        end-if
        set haystack-idx up by 1
    end-perform.
end function substr-count.

*>*
*> Count the number of substring occurrences. Case-insensitive.
*> 
*> @param l-haystack String to search in
*> @param l-needle String to search for
*> @return Number of occurrences
*>*
identification division.
function-id. substr-icount.
environment division.
configuration section.
repository. 
    function lower-case intrinsic
    function substr-count.
data division.
working-storage section.
linkage section.
    01 l-haystack pic x any length.
    01 l-needle pic x any length.
    01 l-result usage binary-long unsigned value 0.
procedure division using l-haystack, l-needle returning l-result.
    move substr-count(lower-case(l-haystack), lower-case(l-needle)) to l-result.
end function substr-icount.

*>*
*> Generate SHA3-256 message digest
*> 
*> @param l-buffer Input bytes
*> @return 64 hexadecimal chars
*>*
identification division.
function-id. sha3-256.
environment division.
configuration section.
repository. 
    function byte-to-hex 
    function byte-length intrinsic.
data division.
working-storage section.
    78 RATE value 1088.
    78 CAPACITY value 512.
    78 SUFFIX value x"06".
    01 ws-idx usage index.
    01 ws-hash pic x(32).
linkage section.
    01 l-buffer pic x any length.
    01 l-hex.
        05 hex pic x(2) occurs 32 times.
procedure division using l-buffer returning l-hex.
    call "KECCAK" using 
        RATE
        CAPACITY
        l-buffer
        byte-length(l-buffer)
        SUFFIX
        ws-hash 
        byte-length(ws-hash).
    perform varying ws-idx from 1 by 1 until ws-idx > byte-length(ws-hash)
        move byte-to-hex(ws-hash(ws-idx:1)) to hex(ws-idx)
    end-perform.
end function sha3-256.

*>*
*> Generate SHA3-512 message digest
*> 
*> @param l-buffer Input bytes
*> @return 128 hexadecimal chars
*>*
identification division.
function-id. sha3-512.
environment division.
configuration section.
repository. 
    function byte-to-hex 
    function byte-length intrinsic.
data division.
working-storage section.
    78 RATE value 576.
    78 CAPACITY value 1024.
    78 SUFFIX value x"06".
    01 ws-idx usage index.
    01 ws-hash pic x(64).
linkage section.
    01 l-buffer pic x any length.
    01 l-hex.
        05 hex pic x(2) occurs 64 times.
procedure division using l-buffer returning l-hex.
    call "KECCAK" using 
        RATE
        CAPACITY
        l-buffer
        byte-length(l-buffer)
        SUFFIX
        ws-hash 
        byte-length(ws-hash).
    perform varying ws-idx from 1 by 1 until ws-idx > byte-length(ws-hash)
        move byte-to-hex(ws-hash(ws-idx:1)) to hex(ws-idx)
    end-perform.
end function sha3-512.
