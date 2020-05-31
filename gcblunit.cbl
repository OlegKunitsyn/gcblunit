       >>SOURCE FORMAT FREE
*>****
*>  GCBLUnit
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
*>****

>>DEFINE constant VERSION as "0.22.1"

identification division.
program-id. runner.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    78 FAILURES-LIMIT value 99.
    78 LINEBREAK value x"0a".
    01 COLOR-GREEN pic x(5) value x"1b5b33326d".
    01 COLOR-RED pic x(5) value x"1b5b33316d".
    01 COLOR-YELLOW pic x(5) value x"1b5b33336d".
    01 COLOR-RESET pic x(4) value x"1b5b306d".
    01 INTRO.
        03 filler pic x(8) value "GCBLUnit".
        03 filler pic x.
        03 filler pic x(7) value VERSION.
        03 filler pic x.
        03 filler pic x(35) value "by Olegs Kunicins and contributors.".
    01 HELP.
        03 filler pic x(80) value 
        "Usage:".
        03 filler pic x value LINEBREAK.
        03 filler pic x(100) value 
        "  cobc -x -debug gcblunit.cbl first-test.cbl [next-test.cbl] --job='first-test [next-test]'".
        03 filler pic x value LINEBREAK.
        03 filler pic x(80) value 
        "  cobc -x -debug gcblunit.cbl --job=Options".
        03 filler pic x value LINEBREAK.
        03 filler pic x value LINEBREAK.
        03 filler pic x(80) value 
        "Options:".
        03 filler pic x value LINEBREAK.
        03 filler pic x(80) value 
        "  -h|-help                 Print this help".
        03 filler pic x value LINEBREAK.
        03 filler pic x(80) value 
        "  -v|--version             Print the version".
        03 filler pic x value LINEBREAK.
    
    01 failures-index usage binary-long unsigned.
    01 end-time.
        03 hours pic 9(2).
        03 minutes pic 9(2).
        03 seconds pic 9(2).
    01 elapsed-time.
        03 hours pic 9(2).
        03 minutes pic 9(2).
        03 seconds pic 9(2).
    77 test-pointer usage program-pointer.
        88 test-skipped value NULL.
    01 test-name pic x(128).
    01 tests-found usage binary-long unsigned.
    01 tests-skipped usage binary-long unsigned.
    01 tests-exceptions usage binary-long unsigned.
    01 assertions-pointer usage pointer external.
    01 failures-counter usage binary-long unsigned external.
    01 assertions.
        03 assertions-total usage binary-long unsigned.
        03 assertions-failed usage binary-long unsigned.
        03 assertions-passed usage binary-long unsigned.
        03 failures occurs 0 to FAILURES-LIMIT times depending on failures-counter.
            05 test-caller pic x(32).
            05 filler pic x value "#".
            05 test-nr pic 9(2).
            05 filler pic x.
            05 assertion pic x(16).
            05 test-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 test-actual pic x(32).

    01 argv pic x(256).
        88 option-help value "-h", "--help".
        88 option-version value "-v", "--version".
procedure division.
    *> accept tmp-dir from environment "TMPDIR".
    *> call "CBL_GET_CURRENT_DIR" using by value 0, by value 255, by reference current-dir.

    perform cblu-start.

    accept argv from ARGUMENT-VALUE.
    perform until argv = SPACE
       evaluate TRUE
       when option-help
           display HELP
           stop run
       when option-version
           stop run
       when other
           move argv to test-name
           perform cblu-exec
       end-evaluate
           move SPACE to argv
           accept argv from ARGUMENT-VALUE
    end-perform.

    perform cblu-finish.
    stop run.

cblu-start section.
    set environment "COB_SCREEN_EXCEPTIONS" TO 'Y'.
    set environment "COB_DISPLAY_WARNINGS" to 'Y'.
    set environment "COB_SET_DEBUG" to 'Y'.
    set assertions-pointer to address of assertions.
    display INTRO LINEBREAK.
    >>IF DEBUG IS NOT SET
       display "Warning: debug mode disabled"
    >>END-IF
    accept elapsed-time from TIME.

cblu-exec section.
    call "CBL_EXIT_PROC" USING 0, ADDRESS OF ENTRY "interruption-handler".
    call "CBL_ERROR_PROC" USING 0, ADDRESS OF ENTRY "exception-handler".
    set test-pointer to entry test-name.
    if test-skipped
       add 1 to tests-skipped
    else
       add 1 to tests-found
       call test-pointer 
    end-if.
    if EXCEPTION-STATUS <> SPACE and trim(EXCEPTION-LOCATION) (1:length(trim(test-name))) = trim(test-name)
       add 1 to tests-exceptions
       display LINEBREAK "There was an exception: " 
           trim(EXCEPTION-STATUS) " in " EXCEPTION-LOCATION " on " EXCEPTION-STATEMENT
    end-if.

cblu-finish section.
    accept end-time from TIME.
    subtract corresponding end-time from elapsed-time.
    call "CBL_EXIT_PROC" using 1, address OF entry 'exception-handler'.
    call "CBL_EXIT_PROC" using 1, address OF entry 'interruption-handler'.
    
    *> time
    display LINEBREAK LINEBREAK "Time: " 
        hours of elapsed-time ":" minutes of elapsed-time ":" seconds of elapsed-time.

    *> failures
    if assertions-failed > 0
       display "There was " assertions-failed " failure(s):"
    end-if.
    perform until failures-index >= assertions-failed
        add 1 to failures-index
        display failures(failures-index)
    end-perform.

    *> summary
    display LINEBREAK.
    if tests-exceptions > 0
        display COLOR-RED "EXCEPTIONS!" COLOR-RESET
        move 1 to RETURN-CODE 
    end-if.
    if assertions-failed > 0
        display COLOR-RED "FAILURES!" COLOR-RESET
        move 1 to RETURN-CODE 
    end-if.
    if tests-exceptions = 0 and assertions-failed = 0
       if tests-found > 0 and assertions-total > 0
           display COLOR-GREEN "OK" COLOR-RESET
       else 
           if tests-found = 0
               display COLOR-YELLOW "No tests found" COLOR-RESET
           else 
               display COLOR-YELLOW "No assertions found" COLOR-RESET
           end-if
       end-if
       move 0 to RETURN-CODE 
    end-if.
    display "Tests: " tests-found ", Skipped: " tests-skipped LINEBREAK
       "Assertions: " assertions-total 
       ", Failures: " assertions-failed 
       ", Exceptions: " tests-exceptions.

identification division.
program-id. exception-handler.
environment division.
data division.
working-storage section.
procedure division.
end program exception-handler.

identification division.
program-id. interruption-handler.
environment division.
data division.
working-storage section.
procedure division.
    display SPACE.
    display "Tests were interruped in " MODULE-SOURCE.
end program interruption-handler.
end program runner.




identification division.
program-id. assert-equals.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    78 FAILURES-LIMIT value 99.
    01 failures-counter usage binary-long unsigned external.
    01 assertions-pointer usage pointer external.
    01 assertions-nr pic 9(2).
    *> local
    01 comparison usage binary-long.
    01 idx usage binary-long unsigned.
    01 diff-idx usage binary-long.
    01 diff-length usage binary-long unsigned.
linkage section.
    01 expected pic x any length.
    01 actual pic x any length. 
    01 assertions.
        03 assertions-total usage binary-long unsigned.
        03 assertions-failed usage binary-long unsigned.
        03 assertions-passed usage binary-long unsigned.
        03 failures occurs 0 to FAILURES-LIMIT times depending on failures-counter.
            05 test-caller pic x(32).
            05 filler pic x value "#".
            05 test-nr pic 9(2).
            05 filler pic x.
            05 assertion pic x(16).
            05 test-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 test-actual pic x(32).
procedure division using expected, actual.
    set address of assertions to assertions-pointer.
    add 1 to assertions-total.
    add 1 to assertions-nr.

    move 0 to idx.
    move 0 to comparison.
    perform until idx >= byte-length(actual) or idx >= byte-length(expected)
        add 1 to idx 
        compute comparison = ord(expected(idx:1)) - ord(actual(idx:1))
        if comparison <> 0
            exit perform
        end-if
    end-perform.

    if comparison = 0
        display "." with no advancing
        add 1 to assertions-passed
        goback
    end-if.

    add 1 TO failures-counter.
    move assertions-nr TO test-nr(failures-counter).
    move MODULE-ID TO assertion(failures-counter).
    move MODULE-CALLER-ID TO test-caller(failures-counter).
    display "F" with no advancing.
    add 1 to assertions-failed.

    compute diff-length = byte-length(test-expected(failures-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length > byte-length(expected)
        move byte-length(expected) to diff-length
    end-if.
    move expected(diff-idx:diff-length) to test-expected(failures-counter).
    move actual(diff-idx:diff-length) to test-actual(failures-counter).

end program assert-equals.




identification division.
program-id. assert-notequals.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    78 FAILURES-LIMIT value 99.
    01 failures-counter usage binary-long unsigned external.
    01 assertions-pointer usage pointer external.
    01 assertions-nr pic 9(2).
    *> local
    01 comparison usage binary-long.
    01 idx usage binary-long unsigned.
    01 diff-idx usage binary-long.
    01 diff-length usage binary-long unsigned.
linkage section.
    01 expected pic x any length.
    01 actual pic x any length. 
    01 assertions.
        03 assertions-total usage binary-long unsigned.
        03 assertions-failed usage binary-long unsigned.
        03 assertions-passed usage binary-long unsigned.
        03 failures occurs 0 to FAILURES-LIMIT times depending on failures-counter.
            05 test-caller pic x(32).
            05 filler pic x value "#".
            05 test-nr pic 9(2).
            05 filler pic x.
            05 assertion pic x(16).
            05 test-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 test-actual pic x(32).
procedure division using expected, actual.
    set address of assertions to assertions-pointer.
    add 1 to assertions-total.
    add 1 to assertions-nr.

    move 0 to idx.
    move 0 to comparison.
    perform until idx >= byte-length(actual) or idx >= byte-length(expected)
        add 1 to idx 
        compute comparison = ord(expected(idx:1)) - ord(actual(idx:1))
        if comparison <> 0
            exit perform
        end-if
    end-perform.

    if comparison <> 0
        display "." with no advancing
        add 1 to assertions-passed
        goback
    end-if.

    add 1 TO failures-counter.
    move assertions-nr TO test-nr(failures-counter).
    move MODULE-ID TO assertion(failures-counter).
    move MODULE-CALLER-ID TO test-caller(failures-counter).
    display "F" with no advancing.
    add 1 to assertions-failed.

    compute diff-length = byte-length(test-expected(failures-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length > byte-length(expected)
        move byte-length(expected) to diff-length
    end-if.
    move expected(diff-idx:diff-length) to test-expected(failures-counter).
    move actual(diff-idx:diff-length) to test-actual(failures-counter).
end program assert-notequals.
