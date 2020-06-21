       >>SOURCE FORMAT FREE
*>**
*>  Core library: network
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
*> Send UDP datagram
*> 
*> @param l-host Remote host name or IP address
*> @param l-port Remote port
*> @param l-message Message
*> @return Number of bytes sent
*>*
identification division.
function-id. send-udp.
environment division.
configuration section.
repository. function byte-length intrinsic.
data division.
working-storage section.
    78 AF_INET value 2.
    78 SOCK_DGRAM value 2.
    01 ws-socket usage binary-int.
linkage section.
    01 l-host pic x(128).
    01 l-port  pic x(5).
    01 l-message pic x any length.
    01 l-result usage binary-long unsigned value 0.
procedure division using l-host, l-port, l-message returning l-result.
    initialize l-result all to value.
    call 'connecttoserver' using
        AF_INET
        SOCK_DGRAM
        l-host
        l-port
        ws-socket
    end-call.
    call 'send' using 
        by value ws-socket
        by reference l-message
        by value  byte-length(l-message)
        by value 0
    end-call.
    move RETURN-CODE to l-result.
    call 'close' using by value ws-socket.
end function send-udp.

*>*
*> Prepare a message in syslog format. RFC 3164
*> 
*> @param l-logsource Remote host name or IP address
*> @param l-program Program name
*> @param l-facility Facility code
*> @param l-severity Severity code
*> @param l-message String encoded in UTF-8
*> @return Syslog message
*>*
identification division.
function-id. syslog.
environment division.
configuration section.
repository. 
    function datetime-format
    function trim numval concatenate intrinsic.
data division.
working-storage section.
    01 ws-code usage binary-char unsigned.
    01 ws-syslog-code pic z(3) value SPACE.
linkage section.
    01 l-logsource pic x any length.
    01 l-program pic x any length.
    01 l-facility pic x any length.
    01 l-severity pic x any length.
    01 l-message pic x any length.
    01 l-syslog pic x(1024).
procedure division using l-logsource, l-program, l-facility, l-severity, l-message returning l-syslog.
    move numval(l-severity) to ws-code.
    call "CBL_OR" using numval(l-facility), ws-code by value 1.
    move ws-code to ws-syslog-code.
    move concatenate(
        "<"
        trim(ws-syslog-code)
        ">"
        trim(datetime-format("MMM DD hh:mm:ss", ZERO))
        SPACE
        trim(l-logsource)
        SPACE
        trim(l-program)
        SPACE
        trim(l-message)
        ":"
        SPACE
    ) to l-syslog.
end function syslog.
