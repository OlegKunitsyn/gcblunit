       >>SOURCE FORMAT FREE
*>*****
*>  Test assert-equals
*>
*>  @author Olegs Kunicins
*>  @license GPL
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
*>*****

identification division.
program-id. equals-test.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    copy "copybooks/dd-fixtures" of "tests".
procedure division.
    perform numeric-data-test.
    perform floating-data-test.
    perform alphanumeric-data-test.
    perform misc-test.
    goback.

numeric-data-test section.
    call "assert-equals" using disp of numeric-data, disp of numeric-data.
    call "assert-equals" using disp-u of numeric-data, disp-u of numeric-data.
    call "assert-equals" using dispp of numeric-data, dispp of numeric-data.
    call "assert-equals" using dispp-u of numeric-data, dispp-u of numeric-data.
    call "assert-equals" using disppp of numeric-data, disppp of numeric-data.
    call "assert-equals" using disppp-u of numeric-data, disppp-u of numeric-data.
    call "assert-equals" using bin of numeric-data, bin of numeric-data.
    call "assert-equals" using bin-u of numeric-data, bin-u of numeric-data.
    call "assert-equals" using cmp3 of numeric-data, cmp3 of numeric-data.
    call "assert-equals" using cmp3-u of numeric-data, cmp3-u of numeric-data.
    call "assert-equals" using cmp5 of numeric-data, cmp5 of numeric-data.
    call "assert-equals" using cmp5-u of numeric-data, cmp5-u of numeric-data.
    call "assert-equals" using cmp6 of numeric-data, cmp6 of numeric-data.
    call "assert-equals" using cmpx of numeric-data, cmpx of numeric-data.
    call "assert-equals" using cmpx-u of numeric-data, cmpx-u of numeric-data.
    call "assert-equals" using chr of numeric-data, chr of numeric-data.
    call "assert-equals" using chr-u of numeric-data, chr-u of numeric-data.
    call "assert-equals" using shrt of numeric-data, shrt of numeric-data.
    call "assert-equals" using shrt-u of numeric-data, shrt-u of numeric-data.
    call "assert-equals" using long of numeric-data, long of numeric-data.
    call "assert-equals" using long-u of numeric-data, long-u of numeric-data.
    call "assert-equals" using dble of numeric-data, dble of numeric-data.
    call "assert-equals" using dble-u of numeric-data, dble-u of numeric-data.

floating-data-test section.
    call "assert-equals" using dbl of floating-data, dbl of floating-data.
    call "assert-equals" using flt of floating-data, flt of floating-data.

alphanumeric-data-test section.
    call "assert-equals" using alpnum of alphanumeric-data, alpnum of alphanumeric-data.
    call "assert-equals" using alpha of alphanumeric-data, alpha of alphanumeric-data.

misc-test section.
    call "assert-equals" using " ", " ".
    call "assert-equals" using "abc9xyz", "abc9xyz".
    call "assert-equals" using 
       "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.", 
       "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.".
end program equals-test.
