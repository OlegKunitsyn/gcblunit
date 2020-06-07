       >>SOURCE FORMAT FREE
*>**
*>  Core library: hash
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
