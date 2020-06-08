       >>SOURCE FORMAT FREE
identification division.
program-id. connecttoserver.
*> 
*>  Copyright (C) 2014 Steve Williams <stevewilliams38@gmail.com>
*> 
*>  This program is free software; you can redistribute it and/or
*>  modify it under the terms of the GNU General Public License as
*>  published by the Free Software Foundation; either version 2,
*>  or (at your option) any later version.
*>  
*>  This program is distributed in the hope that it will be useful,
*>  but WITHOUT ANY WARRANTY; without even the implied warranty of
*>  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*>  GNU General Public License for more details.
*>  
*>  You should have received a copy of the GNU General Public
*>  License along with this software; see the file COPYING.
*>  If not, write to the Free Software Foundation, Inc.,
*>  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

data division.
working-storage section.
01 general-message pic x(64).

01 gai-pointer pointer.
01 gai-message pic x(64) based.

01 address-hints.
   03  address-hints-flags binary-int sync.
   03  address-hints-family binary-int sync.
   03  address-hints-socktype binary-int sync.
   03  address-hints-protocol binary-int sync.
   03  address-hints-address-length binary-int sync.
   03  address-hints-address pointer sync.
   03  address-hints-canonname pointer sync.
   03  address-hints-next pointer.
01 getaddrinfo-result pointer.
01 address-info-pointer pointer.
01 address-info based.
   03  address-info-flags binary-int sync.
   03  address-info-family binary-int sync.
   03  address-info-socktype binary-int sync.
   03  address-info-protocol binary-int sync.
   03  address-info-address-length binary-int sync.
   03  address-info-address pointer sync.
   03  address-info-canonname pointer sync.
   03  address-info-next pointer.

01  address-host pic x(128).
01  address-host-service pic x(32).

linkage section.
01 address-family binary-int.
01 address-socktype binary-int.
01 host pic x(128).
01 host-service pic x(32).
01 socket-descriptor binary-int.

procedure division using address-family address-socktype
     host host-service socket-descriptor.

start-connecttoserver.
*>   get the linked list of selected addresses
*>   for this host and host-service
     initialize address-hints
     move address-family to address-hints-family
     move address-socktype to address-hints-socktype
     move spaces to address-host
     string host delimited by space
         x'00' delimited by size
         into address-host
     end-string
     move spaces to address-host-service
     string host-service delimited by space
         x'00' delimited by size
         into address-host-service
     end-string
     call 'getaddrinfo' using
         by content address-host
         by content address-host-service
         by reference address-hints
         by reference getaddrinfo-result
     end-call
     if return-code < 0
         call 'gai_strerror' using by value return-code giving gai-pointer end-call
         set address of gai-message to gai-pointer
         move spaces to general-message
         string 'getaddrinfo failure: ' delimited by size
             gai-message delimited by x'00'
             into general-message
         end-string
         display general-message end-display
         move 0 to socket-descriptor
         goback
     end-if

*>   scan the linked list until we have a connection
     move getaddrinfo-result to address-info-pointer
     perform until address-info-pointer = null
        move 0 to socket-descriptor
        set address of address-info to address-info-pointer
        call 'socket' using
            by value address-info-family
            by value address-info-socktype
            by value 0
            giving socket-descriptor
        end-call
        if return-code <> -1
            call 'connect' using
                by value socket-descriptor
                by value address-info-address
                by value address-info-address-length 
            end-call
            if return-code <> -1
*>              we have a connection
>>D             display 'successful connection '
>>D                 'socket-descriptor = ' socket-descriptor
>>D             end-display
                exit perform
            end-if
            call 'close' using by value socket-descriptor end-call
        end-if
*>      try the next linked list entry
        move address-info-next to address-info-pointer
    end-perform

*>  delete the linked list
    call 'freeaddrinfo' using by value getaddrinfo-result end-call

    if address-info-pointer = null
        move spaces to general-message
        string 'could not connect to ' delimited by size
            host delimited space
            into general-message
        end-string
        display general-message end-display
        move 0 to socket-descriptor
        goback
    end-if
    goback
    .
end program connecttoserver.

