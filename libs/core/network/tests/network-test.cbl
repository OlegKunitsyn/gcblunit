       >>SOURCE FORMAT FREE
*>**
*>  Test core/network
*>**

>>DEFINE CONSTANT SYSLOG-SEVERITY-EMERGENCY 0
>>DEFINE CONSTANT SYSLOG-SEVERITY-ALERT 1
>>DEFINE CONSTANT SYSLOG-SEVERITY-CRITICAL 2
>>DEFINE CONSTANT SYSLOG-SEVERITY-ERRROR 3
>>DEFINE CONSTANT SYSLOG-SEVERITY-WARNING 4
>>DEFINE CONSTANT SYSLOG-SEVERITY-NOTICE 5
>>DEFINE CONSTANT SYSLOG-SEVERITY-INFORMATIONAL 6
>>DEFINE CONSTANT SYSLOG-SEVERITY-DEBUG 7

>>DEFINE CONSTANT SYSLOG-FACILITY-KERN 0
>>DEFINE CONSTANT SYSLOG-FACILITY-USER 8
>>DEFINE CONSTANT SYSLOG-FACILITY-MAIL 16
>>DEFINE CONSTANT SYSLOG-FACILITY-DAEMON 24
>>DEFINE CONSTANT SYSLOG-FACILITY-AUTH 32
>>DEFINE CONSTANT SYSLOG-FACILITY-SYSLOG 40
>>DEFINE CONSTANT SYSLOG-FACILITY-LPR 48
>>DEFINE CONSTANT SYSLOG-FACILITY-NEWS 56
>>DEFINE CONSTANT SYSLOG-FACILITY-UUCP 64
>>DEFINE CONSTANT SYSLOG-FACILITY-CRON 72
>>DEFINE CONSTANT SYSLOG-FACILITY-AUTHPRIV 80
>>DEFINE CONSTANT SYSLOG-FACILITY-FTP 88
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL0 128
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL1 136
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL2 144
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL3 152
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL4 160
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL5 168
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL6 176
>>DEFINE CONSTANT SYSLOG-FACILITY-LOCAL7 184

identification division.
program-id. network-test.
environment division.
configuration section.
repository.
    function send-udp
    function syslog.
data division.
working-storage section.
    01 ws-syslog pic x(1024).
procedure division.
    *>perform send-udp-test.
    perform syslog-test.
    goback.

syslog-test section.
    move syslog(
        "logsource"
        "program"
        SYSLOG-FACILITY-USER
        SYSLOG-SEVERITY-ERRROR
        "test message"
    ) to ws-syslog.
    call "assert-equals" using "<11>", ws-syslog(1:5).
    move syslog(
        "logsource"
        "program"
        SYSLOG-FACILITY-LOCAL7
        SYSLOG-SEVERITY-DEBUG
        "test message"
    ) to ws-syslog.
    call "assert-equals" using "<191>", ws-syslog(1:5).
    call "assert-equals" using " logsource program test message: ", ws-syslog(21:33).

send-udp-test section.
    call "assert-equals" using 12, send-udp("ping.online.net", 514, "test message").
end program network-test.
