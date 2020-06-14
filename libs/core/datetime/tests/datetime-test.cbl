       >>SOURCE FORMAT FREE
*>**
*>  Test core/date
*>**
identification division.
program-id. datetime-test.
environment division.
configuration section.
repository.
    function datetime-format.
data division.
working-storage section.

procedure division.
    perform datetime-format-test.
    goback.

datetime-format-test section.
    call "assert-equals" using "11/09/2020", datetime-format("MM/DD/YYYY", "2020110909050474+0200").
    call "assert-equals" using "09-11-2020 09:05:04", datetime-format("DD-MM-YYYY hh:mm:ss", "2020110909050474+0200").
    call "assert-equals" using "9-11-20 9:5:4", datetime-format("D-M-YY h:m:s", "2020110909050474+0200").
    call "assert-equals" using "Mon, 09 Nov 2020 GMT+02:00", datetime-format("EEE, DD MMM YYYY z", "2020110909050474+0200").
    call "assert-equals" using "week: 46, day: 314", datetime-format("week: WW, day: DDD", "2020110909050474+0200").
    call "assert-equals" using "2020-11-09T09:05:04+02:00", datetime-format("YYYY-MM-DDThh:mm:ssx", "2020110909050474+0200").
    call "assert-equals" using "+02:00", datetime-format("x", ZERO).
end program datetime-test.
