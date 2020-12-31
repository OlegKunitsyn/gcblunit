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

>>DEFINE constant VERSION as "1.22.6"

identification division.
program-id. gcblunit.
environment division.
configuration section.
repository. function all intrinsic.
input-output section.
file-control.
    select junit assign to junit-file 
    organization is line sequential
    file status is junit-file-status.
data division.
file section.
fd junit.
    01 junit-line pic x(1024).
working-storage section.
    78 ASSERTIONS-LIMIT value 999.
    78 LINEBREAK value x"0a".
    78 COLOR-GREEN value x"1b5b33326d".
    78 COLOR-RED value x"1b5b33316d".
    78 COLOR-YELLOW value x"1b5b33336d".
    78 COLOR-RESET value x"1b5b306d".
    01 INTRO.
        05 filler pic x(8) value "GCBLUnit".
        05 filler pic x.
        05 filler pic x(7) value VERSION.
        05 filler pic x.
        05 filler pic x(35) value "by Olegs Kunicins and contributors.".
    01 HELP.
        05 filler pic x(80) value 
        "Usage:".
        05 filler pic x value LINEBREAK.
        05 filler pic x(100) value 
        "  cobc -x -debug gcblunit.cbl first-test.cbl [next-test.cbl] --job='first-test [next-test]'".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  cobc -x -debug gcblunit.cbl --job=Options".
        05 filler pic x value LINEBREAK.
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "Options:".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  -h, -help                Print this help".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  -v, --version            Print the version".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  --stop-on-error          Stop on the first error".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  --stop-on-failure        Stop on the first failure".
        05 filler pic x value LINEBREAK.
        05 filler pic x(80) value 
        "  --junit report.xml       Report in JUnit XML format".
        05 filler pic x value LINEBREAK.
    
    01 assertions-counter usage binary-long unsigned external.
    01 summary-pointer usage pointer external.
    01 summary.
        03 assertions-total usage binary-long unsigned.
        03 failures-total usage binary-long unsigned.
        03 assertions occurs 0 to ASSERTIONS-LIMIT times depending on assertions-counter.
            05 assertion-status pic x.
                88 assertion-failed value "F".
            05 filler pic x.
            05 assertion-suite pic x(32).
            05 filler pic x value "#".
            05 assertion-nr pic 9(2).
            05 filler pic x.
            05 assertion-name pic x(16).
            05 filler pic x.
            05 assertion-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 assertion-actual pic x(32).

    01 argv pic x(256).
        88 option-help value "-h", "--help".
        88 option-version value "-v", "--version".
        88 option-junit value "--junit".
        88 option-stop-on-error value "--stop-on-error".
        88 option-stop-on-failure value "--stop-on-failure".
    
    01 junit-file pic x(256).
        88 is-empty value SPACE.
    01 junit-file-status pic x(2).
        88 junit-ok value "00".
    01 junit-testsuite.
        05 filler pic x(36) value '  <testsuite name="GCBLUnit" tests="'.
        05 junit-tests pic x(9).
        05 filler pic x(14) value '" assertions="'.
        05 junit-assertions pic x(9).
        05 filler pic x(10) value '" errors="'.
        05 junit-errors pic x(9).
        05 filler pic x(12) value '" failures="'.
        05 junit-failures pic x(9).
        05 filler pic x(11) value '" skipped="'.
        05 junit-skipped pic x(9).
        05 filler pic x(8) value '" time="'.
        05 junit-time pic x(9).
        05 filler pic x(2) value '">'.
    01 junit-elapsed-time usage binary-long unsigned.

    01 ws-stop-on-error usage binary-short value 0.
    01 ws-stop-on-failure usage binary-short value 0.

    *> local
    01 assertions-index usage binary-long unsigned.
    01 first-suite pic x(32).
       88 is-empty value SPACE.
    01 current-time.
        05 hours pic 9(2).
        05 minutes pic 9(2).
        05 seconds pic 9(2).
    01 elapsed-time.
        05 hours pic 9(2).
        05 minutes pic 9(2).
        05 seconds pic 9(2).
    77 test-pointer usage program-pointer.
        88 test-skipped value NULL.
    01 testsuite-name pic x(128).
    01 tests-total usage binary-long unsigned.
    01 skipped-total usage binary-long unsigned.
    01 errors-total usage binary-long unsigned.
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
        when option-junit
            move SPACE to argv
            accept argv from ARGUMENT-VALUE
            move argv to junit-file
        when option-stop-on-error
            move 1 to ws-stop-on-error
        when option-stop-on-failure
            move 1 to ws-stop-on-failure
        when other
            move argv to testsuite-name
            perform cblu-exec
            if ws-stop-on-failure = 1 and failures-total > 0
               exit perform
            end-if
            if ws-stop-on-error = 1 and errors-total > 0
               exit perform
            end-if
        end-evaluate
            move SPACE to argv
            accept argv from ARGUMENT-VALUE
    end-perform.

    perform cblu-finish.

    if not is-empty of junit-file
        perform cblu-junit
    end-if.
    stop run.

cblu-start section.
    set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
    set environment "COB_DISPLAY_WARNINGS" to 'Y'.
    set environment "COB_SET_DEBUG" to 'Y'.
    set summary-pointer to address of summary.
    display INTRO LINEBREAK.
    >>IF DEBUG IS NOT SET
       display "Warning: debug mode disabled"
    >>END-IF
    accept elapsed-time from TIME.

cblu-exec section.
    call "CBL_EXIT_PROC" using 0, address of entry "interruption-handler".
    call "CBL_ERROR_PROC" using 0, address of entry "exception-handler".
    set test-pointer to entry testsuite-name.
    if test-skipped
        add 1 to skipped-total
    else
        add 1 to tests-total
        call test-pointer
    end-if.
    if EXCEPTION-STATUS <> SPACE and trim(EXCEPTION-LOCATION) (1:length(trim(testsuite-name))) = trim(testsuite-name)
        add 1 to errors-total
        display LINEBREAK "There was an exception: " 
            trim(EXCEPTION-STATUS) " in " EXCEPTION-LOCATION " on " EXCEPTION-STATEMENT
    end-if.
    call "CBL_ERROR_PROC" using 1, address of entry "exception-handler".
    call "CBL_EXIT_PROC" using 1, address of entry "interruption-handler".

cblu-finish section.
    accept current-time from TIME.
    subtract corresponding current-time from elapsed-time.
    
    *> time
    display LINEBREAK LINEBREAK "Time: " 
        hours of elapsed-time ":" minutes of elapsed-time ":" seconds of elapsed-time.

    *> failures
    if failures-total of summary > 0
        display "There was " failures-total of summary " failure(s):"
    end-if.
    move 0 to assertions-index.
    perform until assertions-index >= assertions-total of summary
        add 1 to assertions-index
        if assertion-failed(assertions-index)
            display assertions(assertions-index)
        end-if
    end-perform.

    *> report
    display LINEBREAK.
    if errors-total > 0
        display COLOR-RED "EXCEPTIONS!" COLOR-RESET
        move 1 to RETURN-CODE 
    end-if.
    if failures-total of summary > 0
        display COLOR-RED "FAILURES!" COLOR-RESET
        move 1 to RETURN-CODE 
    end-if.
    if errors-total = 0 and failures-total of summary = 0
       if tests-total > 0 and assertions-total of summary > 0
           display COLOR-GREEN "OK" COLOR-RESET
       else 
           if tests-total = 0
               display COLOR-YELLOW "No tests found" COLOR-RESET
           else 
               display COLOR-YELLOW "No assertions found" COLOR-RESET
           end-if
       end-if
       move 0 to RETURN-CODE 
    end-if.
    display "Tests: " tests-total ", Skipped: " skipped-total LINEBREAK
       "Assertions: " assertions-total of summary
       ", Failures: " failures-total of summary
       ", Exceptions: " errors-total.

cblu-junit section.
    open output junit.
    if not junit-ok
        display "Error writing " junit-file ": " junit-file-status upon syserr
    end-if.

    *> cover
    move '<?xml version="1.0" encoding="UTF-8"?>' to junit-line.
    write junit-line.
    move '<testsuites>' to junit-line.
    write junit-line.

    move tests-total to junit-tests of junit-testsuite.
    move skipped-total to junit-skipped of junit-testsuite.
    move assertions-total to junit-assertions of junit-testsuite.
    move failures-total to junit-failures of junit-testsuite.
    move errors-total to junit-errors of junit-testsuite.
    compute junit-elapsed-time = 3600 * hours of elapsed-time 
        + 60 * minutes of elapsed-time 
        + seconds of elapsed-time.
    move junit-elapsed-time to junit-time.
    move junit-testsuite to junit-line.
    write junit-line.
    
    *> cases
    move 0 to assertions-index.
    perform until assertions-index >= assertions-total of summary
        add 1 to assertions-index

        *> suite
        if first-suite <> assertion-suite(assertions-index)        
            if not is-empty of first-suite
               move '    </testsuite>' to junit-line
               write junit-line
            end-if
            move concatenate(
                '    <testsuite name="', trim(assertion-suite(assertions-index)), '">'
            ) to junit-line
            write junit-line
            move assertion-suite(assertions-index) to first-suite    
        end-if

        *> case
        move concatenate(
            '      <testcase name="', trim(assertion-name(assertions-index)),
            '" file="', trim(assertion-suite(assertions-index)),
            '" line="', assertion-nr(assertions-index),
            '" assertions="1">'
        ) to junit-line
        write junit-line
        
        *> failure
        if assertion-failed(assertions-index)
            move concatenate(
               '        <failure type="', trim(assertion-name(assertions-index)),
                '"><![CDATA[', assertions(assertions-index), ']]></failure>'
            ) to junit-line
            write junit-line
        end-if
        
        *> /case
        move '      </testcase>' to junit-line
        write junit-line
    end-perform.

    move '    </testsuite>' to junit-line
    write junit-line
    move '  </testsuite>' to junit-line
    write junit-line.
    move '</testsuites>' to junit-line
    write junit-line.
    close junit.
    if not junit-ok
        display "Error closing " junit-file ": " junit-file-status upon syserr
    end-if.

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
end program gcblunit.




identification division.
program-id. assert-equals.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    78 ASSERTIONS-LIMIT value 999.
    01 assertions-counter usage binary-long unsigned external.
    01 summary-pointer usage pointer external.
    01 assertions-nr pic 9(2).
    *> local
    01 comparison usage binary-long.
    01 idx usage binary-long unsigned.
    01 diff-idx usage binary-long.
    01 diff-length usage binary-long unsigned.
    01 diff-numeric usage binary-long based.
linkage section.
    01 expected pic x any length.
    01 actual pic x any length. 
    01 summary.
        03 assertions-total usage binary-long unsigned.
        03 failures-total usage binary-long unsigned.
        03 assertions occurs 0 to ASSERTIONS-LIMIT times depending on assertions-counter.
            05 assertion-status pic x.
               88 assertion-failed value "F".
            05 filler pic x.
            05 assertion-suite pic x(32).
            05 filler pic x value "#".
            05 assertion-nr pic 9(2).
            05 filler pic x.
            05 assertion-name pic x(16).
            05 filler pic x.
            05 assertion-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 assertion-actual pic x(32).
procedure division using expected, actual.
    set address of summary to summary-pointer.
    add 1 to assertions-total.
    add 1 to assertions-nr.
    add 1 to assertions-counter.
    move assertions-nr to assertion-nr(assertions-counter).
    move MODULE-ID to assertion-name(assertions-counter).
    move MODULE-CALLER-ID to assertion-suite(assertions-counter).

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
        move "." to assertion-status(assertions-counter)
    else
        move "F" to assertion-status(assertions-counter)
        add 1 to failures-total
    end-if.
    
    *> show status
    display assertion-status(assertions-counter) with no advancing.
    
    *> show diff
    compute diff-length = byte-length(assertion-expected(assertions-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length + diff-idx > byte-length(expected)
        compute diff-length = byte-length(expected) - diff-idx + 1
    end-if.
    move expected(diff-idx:diff-length) to assertion-expected(assertions-counter).

    compute diff-length = byte-length(assertion-actual(assertions-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length + diff-idx > byte-length(actual)
        compute diff-length = byte-length(actual) - diff-idx + 1
    end-if.
    move actual(diff-idx:diff-length) to assertion-actual(assertions-counter).
end program assert-equals.




identification division.
program-id. assert-notequals.
environment division.
configuration section.
repository. function all intrinsic.
data division.
working-storage section.
    78 ASSERTIONS-LIMIT value 999.
    01 assertions-counter usage binary-long unsigned external.
    01 summary-pointer usage pointer external.
    01 assertions-nr pic 9(2).
    *> local
    01 comparison usage binary-long.
    01 idx usage binary-long unsigned.
    01 diff-idx usage binary-long.
    01 diff-length usage binary-long unsigned.
    01 diff-numeric usage binary-long based.
linkage section.
    01 expected pic x any length.
    01 actual pic x any length. 
    01 summary.
        03 assertions-total usage binary-long unsigned.
        03 failures-total usage binary-long unsigned.
        03 assertions occurs 0 to ASSERTIONS-LIMIT times depending on assertions-counter.
            05 assertion-status pic x.
               88 assertion-failed value "F".
            05 filler pic x.
            05 assertion-suite pic x(32).
            05 filler pic x value "#".
            05 assertion-nr pic 9(2).
            05 filler pic x.
            05 assertion-name pic x(16).
            05 filler pic x.
            05 assertion-expected pic x(32).
            05 filler pic x(4) value " <> ".
            05 assertion-actual pic x(32).
procedure division using expected, actual.
    set address of summary to summary-pointer.
    add 1 to assertions-total.
    add 1 to assertions-nr.
    add 1 to assertions-counter.
    move assertions-nr to assertion-nr(assertions-counter).
    move MODULE-ID to assertion-name(assertions-counter).
    move MODULE-CALLER-ID to assertion-suite(assertions-counter).

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
        move "." to assertion-status(assertions-counter)
    else
        move "F" to assertion-status(assertions-counter)
        add 1 to failures-total
    end-if.
    
    *> show status
    display assertion-status(assertions-counter) with no advancing.

    *> show diff
    compute diff-length = byte-length(assertion-expected(assertions-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length + diff-idx > byte-length(expected)
        compute diff-length = byte-length(expected) - diff-idx + 1
    end-if.
    move expected(diff-idx:diff-length) to assertion-expected(assertions-counter).

    compute diff-length = byte-length(assertion-actual(assertions-counter)).
    compute diff-idx = idx - (0.5 * diff-length - 1).
    if diff-idx < 1
        move 1 to diff-idx
    end-if.
    if diff-length + diff-idx > byte-length(actual)
        compute diff-length = byte-length(actual) - diff-idx + 1
    end-if.
    move actual(diff-idx:diff-length) to assertion-actual(assertions-counter).
end program assert-notequals.
