<h1 align="center">
  <br>
    <img src="https://github.com/OlegKunitsyn/gcblunit/blob/master/icon.png?raw=true" alt="logo" width="200">
  <br>
  GCBLUnit framework
  <br>
  <br>
</h1>

<h4 align="center">Simple Unit Testing for GnuCOBOL written in GnuCOBOL.</h4>

<p align="center">
  <img src="https://github.com/OlegKunitsyn/gcblunit/workflows/Docker%20Image%20CI/badge.svg?branch=master" />
</p>

### Features
* Assertions
* Reporting in JUnit format
* Continuous Integration
* No mainframe required
* GnuCOBOL Docker

```
$ cobc -x -debug gcblunit.cbl tests/intrinsic/* --job='equals-test notequals-test'
GCBLUnit 0.22.2  by Olegs Kunicins and contributors.

..............................................................

Time: 00:00:00

OK
Tests: 0000000002, Skipped: 0000000000
Assertions: 0000000062, Failures: 0000000000, Exceptions: 0000000000                                  
```

### Requirements
You may choose between *local* and *container* execution environment.

#### Local
GnuCOBOL `cobc` 2.2+ installed.

#### Container
[GnuCOBOL Docker](https://hub.docker.com/repository/docker/olegkunitsyn/gnucobol) container up and running. 
The image includes GnuCOBOL and all required dependencies needed to debug or execute your code.

### Installation
Simply download [gcblunit.cbl](https://github.com/OlegKunitsyn/gcblunit/blob/master/gcblunit.cbl?raw=true). That's it.

```
$ cobc -x gcblunit.cbl --job=-h
GCBLUnit 0.22.2  by Olegs Kunicins and contributors.

Usage:                                                                          
  cobc -x -debug gcblunit.cbl first-test.cbl [next-test.cbl] --job='first-test [next-test]'         
  cobc -x -debug gcblunit.cbl --job=Options                                     

Options:
  -h|-help                 Print this help
  -v|--version             Print the version
  --junit report.xml       Report in JUnit XML format
```

### Writing Tests
Tests are simple COBOL programs that allow futher execution (without `stop run`). There is no code-generation tricks nor injections.
The assertions are GnuCOBOL programs and await two values - expected and actual, respectively:

```
call "assert-equals" using "expected", "actual".                                
```

This assertion, once included into the unit-testing, will lead to one failed test. More examples you may find in the `tests` directory.

At the moment these assertions are supported:
 - assert-equals
 - assert-notequals

 GCBLUnit catches exceptions and stops. For instance, the statement `compute y = y / 0.` is getting reported this way: 
 
```
GCBLUnit 0.22.2  by Olegs Kunicins and contributors.

There was an exception: EC-SIZE-OVERFLOW in exception-test; ; 33 on COMPUTE                        

Time: 00:00:00

EXCEPTIONS!
Tests: 0000000001, Skipped: 0000000000
Assertions: 0000000000, Failures: 0000000000, Exceptions: 0000000001                       
```

### Continuous Integration
COBOLUnit returns an exit-code of the execution that is usually enough for CI pipelines.
Additional details you may export to a file in JUnit XML format by using `--junit` option.

### Alternatives
GCBLUnit primarily focuses on Unit Testing - isolated GnuCOBOL functions and programs with an input and output.

Nonetheless, you may try two alternatives as well:
 - `cobol-unit-test` - a paragraph-level Unit Testing framework, written by Dave Nicolette, hosted on [GitHub](https://github.com/neopragma/cobol-unit-test/wiki).
 - `COBOLUnit` - a full-featured Unit Testing framework for COBOL, written by Hervé Vaujour, hosted on [Google Sites](https://sites.google.com/site/cobolunit/). Not updated since 2010.

### TODO
 - Stop upon the first exception `--stop-on-exception`
 - Stop upon the first failed test `--stop-on-failed`
 - Stop upon the first skipped test `--stop-on-skipped`
 - Assertion `assert-greater`
 - Assertion `assert-less`
 - Auto-discovery of the tests in the compilation group

Your contribution is always welcome!
