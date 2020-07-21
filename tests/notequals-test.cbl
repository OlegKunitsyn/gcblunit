       >>SOURCE FORMAT FREE
*>**
*>  Test assert-notequals
*>**

identification division.
program-id. notequals-test.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    copy "dd-fixtures" of "copybooks".
procedure division.
    perform numeric-data-test.
    perform floating-data-test.
    perform alphanumeric-data-test.
    perform misc-test.
    goback.

numeric-data-test section.
    call "assert-notequals" using disp of numeric-data-alt, disp of numeric-data.
    call "assert-notequals" using disp-u of numeric-data-alt, disp-u of numeric-data.
    call "assert-notequals" using dispp of numeric-data-alt, dispp of numeric-data.
    call "assert-notequals" using dispp-u of numeric-data-alt, dispp-u of numeric-data.
    call "assert-notequals" using disppp of numeric-data-alt, disppp of numeric-data.
    call "assert-notequals" using disppp-u of numeric-data-alt, disppp-u of numeric-data.
    call "assert-notequals" using bin of numeric-data-alt, bin of numeric-data.
    call "assert-notequals" using bin-u of numeric-data-alt, bin-u of numeric-data.
    call "assert-notequals" using cmp3 of numeric-data-alt, cmp3 of numeric-data.
    call "assert-notequals" using cmp3-u of numeric-data-alt, cmp3-u of numeric-data.
    call "assert-notequals" using cmp5 of numeric-data-alt, cmp5 of numeric-data.
    call "assert-notequals" using cmp5-u of numeric-data-alt, cmp5-u of numeric-data.
    call "assert-notequals" using cmp6 of numeric-data-alt, cmp6 of numeric-data.
    call "assert-notequals" using cmpx of numeric-data-alt, cmpx of numeric-data.
    call "assert-notequals" using cmpx-u of numeric-data-alt, cmpx-u of numeric-data.
    call "assert-notequals" using chr of numeric-data-alt, chr of numeric-data.
    call "assert-notequals" using chr-u of numeric-data-alt, chr-u of numeric-data.
    call "assert-notequals" using shrt of numeric-data-alt, shrt of numeric-data.
    call "assert-notequals" using shrt-u of numeric-data-alt, shrt-u of numeric-data.
    call "assert-notequals" using long of numeric-data-alt, long of numeric-data.
    call "assert-notequals" using long-u of numeric-data-alt, long-u of numeric-data.
    call "assert-notequals" using dble of numeric-data-alt, dble of numeric-data.
    call "assert-notequals" using dble-u of numeric-data-alt, dble-u of numeric-data.

floating-data-test section.
    call "assert-notequals" using dbl of floating-data-alt, dbl of floating-data.
    call "assert-notequals" using flt of floating-data-alt, flt of floating-data.

alphanumeric-data-test section.
    call "assert-notequals" using alpnum of alphanumeric-data-alt, alpnum of alphanumeric-data.
    call "assert-notequals" using alpha of alphanumeric-data-alt, alpha of alphanumeric-data.
    call "assert-notequals" using edit-num1 of alphanumeric-data-alt, edit-num1 of alphanumeric-data.
    call "assert-notequals" using edit-num2 of alphanumeric-data-alt, edit-num2 of alphanumeric-data.
    call "assert-notequals" using edit-num3 of alphanumeric-data-alt, edit-num3 of alphanumeric-data.

misc-test section.
    call "assert-notequals" using "abc9xyz", "abc8xyz".
    call "assert-notequals" using 
       "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.", 
       "Lorem ipsum dolor sit amet, consectetuer adipiscing elitAenean commodo ligula eget dolor.".
end program notequals-test.
