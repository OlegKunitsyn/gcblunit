       >>SOURCE FORMAT FREE
*>**
*>  Test core/hash
*>**
identification division.
program-id. hash-test.
environment division.
configuration section.
repository.
    function sha3-256
    function sha3-512.
data division.
working-storage section.
procedure division.
    perform sha3-256-test.
    perform sha3-512-test.
    goback.

sha3-256-test section.
    call "assert-equals" using 
        "60E893E6D54D8526E55A81F98BFAC5DA236BB203E84ED5967A8F527D5BF3D4A4"
        sha3-256(SPACE).

sha3-512-test section.
    call "assert-equals" using 
        "E307DAEA2F0168DAA1318E2FAA2D67791E9D8E03692A6F7D1EB974E664FE721E81A47B4CF3D0EB19AE5D57AFA19A095941CAD5A5C050774AD56A8E5E21105757" 
        sha3-512(SPACE).
end program hash-test.
