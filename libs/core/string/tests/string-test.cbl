       >>SOURCE FORMAT FREE
*>**
*>  Test core/string
*>**
identification division.
program-id. string-test.
environment division.
configuration section.
repository.
    function urlencoded-to-byte
    function byte-to-urlencoded
    function sha3-256
    function sha3-512
    function substr-pos
    function substr-pos-case
    function byte-to-hex
    function hex-to-byte
    function substr-count
    function substr-count-case.
data division.
working-storage section.
procedure division.
    perform byte-to-urlencoded-test.
    perform urlencoded-to-byte-test.
    perform sha3-256-test.
    perform sha3-512-test.
    perform substr-count-test.
    perform substr-pos-test.
    perform substr-pos-case-test.
    perform byte-to-hex-test.
    perform hex-to-byte-test.
    goback.

urlencoded-to-byte-test section.
    call "assert-equals" using x"20", urlencoded-to-byte("%20").
    call "assert-equals" using x"FF", urlencoded-to-byte("%FF").
    call "assert-equals" using x"00", urlencoded-to-byte(SPACES).

byte-to-urlencoded-test section.
    call "assert-equals" using "%20", byte-to-urlencoded(x"20").
    call "assert-equals" using "%FF", byte-to-urlencoded(x"FF").
    call "assert-equals" using "%00", byte-to-urlencoded(x"00").

sha3-256-test section.
    call "assert-equals" using 
        "60E893E6D54D8526E55A81F98BFAC5DA236BB203E84ED5967A8F527D5BF3D4A4"
        sha3-256(SPACE).

sha3-512-test section.
    call "assert-equals" using 
        "E307DAEA2F0168DAA1318E2FAA2D67791E9D8E03692A6F7D1EB974E664FE721E81A47B4CF3D0EB19AE5D57AFA19A095941CAD5A5C050774AD56A8E5E21105757" 
        sha3-512(SPACE).

hex-to-byte-test section.
    call "assert-equals" using x"00", hex-to-byte("00").
    call "assert-equals" using x"FF", hex-to-byte("ff").
    call "assert-equals" using x"20", hex-to-byte("20").
    call "assert-equals" using x"0A", hex-to-byte("0A").

byte-to-hex-test section.
    call "assert-equals" using "00", byte-to-hex(x"00").
    call "assert-equals" using "FF", byte-to-hex(x"ff").
    call "assert-equals" using "20", byte-to-hex(SPACE).
    call "assert-equals" using "0A", byte-to-hex(x"0a").

substr-pos-test section.
    call "assert-equals" using 1, substr-pos(SPACE, SPACE).
    call "assert-equals" using 1, substr-pos("Lorem ipsum dolor", "Lorem").
    call "assert-equals" using 0, substr-pos("Lorem ipsum dolor", "lorem").
    call "assert-equals" using 12, substr-pos("Lorem ipsum dolor", " dolor").
    call "assert-equals" using 0, substr-pos("Lorem ipsum", "Lorem ipsum ").

substr-pos-case-test section.
    call "assert-equals" using 1, substr-pos-case(SPACE, SPACE).
    call "assert-equals" using 1, substr-pos-case("Lorem ipsum dolor", "Lorem").
    call "assert-equals" using 1, substr-pos-case("Lorem ipsum dolor", "lorem").
    call "assert-equals" using 12, substr-pos-case("Lorem ipsum dolor", " Dolor").
    call "assert-equals" using 1, substr-pos-case("Lorem ipsum", "lorem ipsum").

substr-count-test section.
    call "assert-equals" using 1, substr-count(SPACE, SPACE).
    call "assert-equals" using 1, substr-count("Lorem ipsum dolor", "Lorem").
    call "assert-equals" using 0, substr-count("Lorem ipsum dolor", "lorem").
    call "assert-equals" using 1, substr-count("Lorem ipsum dolor", " dolor").
    call "assert-equals" using 2, substr-count("Lorem ipsum", "m").

substr-count-case-test section.
    call "assert-equals" using 1, substr-count-case(SPACE, SPACE).
    call "assert-equals" using 1, substr-count-case("Lorem ipsum dolor", "Lorem").
    call "assert-equals" using 1, substr-count-case("Lorem ipsum dolor", "lorem").
    call "assert-equals" using 1, substr-count-case("Lorem ipsum dolor", " dolor").
    call "assert-equals" using 2, substr-count-case("Lorem ipsum", "M").
end program string-test.
