       >>SOURCE FORMAT FREE
*>**
*>  Core library: datetime
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
*> Format the given or current timestamp, replacing the tokens, such as
*> YY    Year                                      18
*> YYYY  Year                                      2018
*> M     Month of the year (1-12)                  7
*> MM    Month of the year (01-12)                 07
*> MMM   Month of the year textual                 Jul
*> D     Day of the month (1-31)                   9
*> DD    Day of the month (01-31)                  09
*> DDD   Day of the year (01-366)                  07
*> WW    Week of the year (01-53)                  05
*> U     Weekday (1-7)                             2
*> EEE   Weekday textual      	                   Tue
*> h     Hour of the day (0-23)                    5
*> hh    Hour of the day (00-23)                   05
*> m     Minute of the hour (0-59)                 9
*> mm    Minute of the hour (00-59)                09
*> s     Second of the minute (0-59)               4
*> ss    Second of the minute (00-59)              04
*> z     Timezone                                  GMT-08:00
*> x     Timezone ISO 8601                         -08:00
*> @param l-format 32-char long string
*> @param l-timestamp 21-char long current-date or ZERO
*> @return Formatted timestamp trailing by spaces, 32-char long
*>*
identification division.
function-id. datetime-format.
environment division.
configuration section.
repository. 
    function current-date numval substitute trim formatted-date integer-of-date intrinsic.
data division.
working-storage section.
    01 WEEKDAYS.
        05 filler pic x(3) value "Mon".
        05 filler pic x(3) value "Tue".
        05 filler pic x(3) value "Wed".
        05 filler pic x(3) value "Thu".
        05 filler pic x(3) value "Fri".
        05 filler pic x(3) value "Sat".
        05 filler pic x(3) value "Sun".
    01 filler redefines WEEKDAYS.
        05 ws-eee pic x(3) occurs 7 times indexed by ws-eee-idx.
    01 MONTHS.
        05 filler pic x(3) value "Jan".
        05 filler pic x(3) value "Feb".
        05 filler pic x(3) value "Mar".
        05 filler pic x(3) value "Apr".
        05 filler pic x(3) value "May".
        05 filler pic x(3) value "Jun".
        05 filler pic x(3) value "Jul".
        05 filler pic x(3) value "Aug".
        05 filler pic x(3) value "Sep".
        05 filler pic x(3) value "Oct".
        05 filler pic x(3) value "Nov".
        05 filler pic x(3) value "Dec".
    01 filler redefines MONTHS.
        05 ws-mmm pic x(3) occurs 12 times indexed by ws-mmm-idx.
    01 ws-timestamp.
        05 ts-yyyy.
           10 filler pic 9(2).
           10 ts-yy pic 9(2).
        05 ts-mm pic z(2).
        05 ts-dd pic z(2).
        05 ts-hh pic 9(2).
        05 ts-mmi pic 9(2).
        05 ts-ss pic 9(2).
        05 filler pic 9(2).
        05 ts-gmt-hours pic S9(2) sign leading separate.
        05 ts-gmt-minutes pic 9(2).
    01 ts-week.
        05 filler pic 9(5).
        05 ts-ww pic 9(2).
        05 ts-u pic 9(1).
    01 ts-d pic z(2) value space.
    01 ts-m pic z(2) value space.
    01 ts-h pic z(2) value space.
    01 ts-mi pic z(2) value space.
    01 ts-s pic z(2) value space.
    01 ts-z.
        05 filler value "GMT".
        05 ts-gmt-hours pic S9(2) sign leading separate.
        05 filler value ":".
        05 ts-gmt-minutes pic 9(2).
    01 ts-x.
        05 ts-gmt-hours pic S9(2) sign leading separate.
        05 filler value ":".
        05 ts-gmt-minutes pic 9(2).
linkage section.
    01 l-format pic x any length.
    01 l-timestamp pic x any length.
    01 l-result pic x(32).
procedure division using l-format, l-timestamp returning l-result.
    if l-timestamp is ZERO
        move current-date to ws-timestamp
    else
        move l-timestamp to ws-timestamp
    end-if.

    move ts-mm to ts-m.
    move ts-dd to ts-d.
    move ts-hh to ts-h.
    move ts-mmi to ts-mi.
    move ts-ss to ts-s.
    move corresponding ws-timestamp to ts-z.
    move corresponding ws-timestamp to ts-x.
    move numval(ts-mm) to ws-mmm-idx.
    move formatted-date("YYYYWwwD", integer-of-date(numval(ws-timestamp(1:8)))) to ts-week.
    move numval(ts-u) to ws-eee-idx.

    move substitute(
        l-format
        "YYYY" ts-yyyy "YY" ts-yy
        "MMM" ws-mmm(ws-mmm-idx) "MM" ts-mm "M" trim(ts-m)
        "DDD" formatted-date("YYYY-DDD", integer-of-date(numval(ws-timestamp(1:8))))(6:3) 
           "DD" ts-dd "D" trim(ts-d)
        "WW" ts-ww
        "U" trim(ts-u)
        "EEE" ws-eee(ws-eee-idx) 
        "hh" ts-hh "h" trim(ts-h)
        "mm" ts-mmi "m" trim(ts-mi)
        "ss" ts-ss "s" trim(ts-s)
        "z" ts-z
        "x" ts-x
    ) to l-result.
end function datetime-format.
