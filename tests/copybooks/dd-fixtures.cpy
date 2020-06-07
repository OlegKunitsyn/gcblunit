       >>SOURCE FORMAT FREE
*>**
*>  Dataset for tests
*>
*>  @author Simon Sobisch
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

01 numeric-data.
   05 disp     usage display   pic s99v999   value -12.34.
   05 disp-u   usage display   pic  99v999   value  12.34.
   05 dispp    usage display   pic spppp9999 value -.0000123.
   05 dispp-u  usage display   pic  pppp9999 value  .0000123.
   05 disppp   usage display   pic s9999pppp value -12340000.
   05 disppp-u usage display   pic  9999pppp value  12340000.
   05 bin      usage binary    pic s99v999   value -12.34.
   05 bin-u    usage binary    pic  99v999   value  12.34.
   05 cmp3     usage packed-decimal pic s99v999   value -12.34.
   05 cmp3-u   usage packed-decimal pic  99v999   value  12.34.
   05 cmp5     usage comp-5         pic s99v999   value -12.34.
   05 cmp5-u   usage comp-5         pic  99v999   value  12.34.
   05 cmp6     usage comp-6         pic  99v999   value  12.34.
   05 cmpx     usage comp-x         pic s99v999   value -12.34.
   05 cmpx-u   usage comp-x         pic  99v999   value  12.34.
   05 chr      usage binary-char    signed   value -128.
   05 chr-u    usage binary-char    unsigned value 254.
   05 shrt     usage binary-short   signed   value -32768.
   05 shrt-u   usage binary-short   unsigned value 65535.
   05 long     usage binary-long    signed   value -2147483648.
   05 long-u   usage binary-long    unsigned value  4294967295.
   05 dble     usage binary-double  signed   value -4294967295.
   05 dble-u   usage binary-double  unsigned value  8294967295.
01 numeric-data-alt.
   05 disp     usage display   pic s99v999   value -12.35.
   05 disp-u   usage display   pic  99v999   value  12.35.
   05 dispp    usage display   pic spppp9999 value -.0000124.
   05 dispp-u  usage display   pic  pppp9999 value  .0000124.
   05 disppp   usage display   pic s9999pppp value -12350000.
   05 disppp-u usage display   pic  9999pppp value  12350000.
   05 bin      usage binary    pic s99v999   value -12.33.
   05 bin-u    usage binary    pic  99v999   value  12.33.
   05 cmp3     usage packed-decimal pic s99v999   value -12.33.
   05 cmp3-u   usage packed-decimal pic  99v999   value  12.33.
   05 cmp5     usage comp-5         pic s99v999   value -12.33.
   05 cmp5-u   usage comp-5         pic  99v999   value  12.33.
   05 cmp6     usage comp-6         pic  99v999   value  12.33.
   05 cmpx     usage comp-x         pic s99v999   value -12.33.
   05 cmpx-u   usage comp-x         pic  99v999   value  12.33.
   05 chr      usage binary-char    signed   value -127.
   05 chr-u    usage binary-char    unsigned value 253.
   05 shrt     usage binary-short   signed   value -32767.
   05 shrt-u   usage binary-short   unsigned value 65534.
   05 long     usage binary-long    signed   value -2147483647.
   05 long-u   usage binary-long    unsigned value  4294967294.
   05 dble     usage binary-double  signed   value -4294967294.
   05 dble-u   usage binary-double  unsigned value  8294967294.

01 floating-data.
   05 dbl        usage float-long      value -3.40282e+038.
   05 flt        usage float-short     value 3.40282e+038.
01 floating-data-alt.
   05 dbl        usage float-long      value -3.30282e+038.
   05 flt        usage float-short     value 3.30282e+038.

01 alphanumeric-data.
   05 alpnum     pic x(36) value "some numb3rs 4 n00bs l1k3 m3".
   05 alpha      pic a(36) value "thats some text".
   05 edit-num1  pic --9.999.
   05 edit-num2  pic ++9.999.
   05 edit-num3  pic zz9.999.
01 alphanumeric-data-alt.
   05 alpnum     pic x(36) value "some numb3rs 4 n11bs l1k3 m3".
   05 alpha      pic a(36) value "thats sometext".
   05 edit-num1  pic ++9.999.
   05 edit-num2  pic --9.999.
   05 edit-num3  pic -zz9.999.
