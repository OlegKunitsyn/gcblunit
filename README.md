<h1 align="center">
  <br>
    <img src="https://github.com/OlegKunitsyn/gcblunit/blob/master/icon.png?raw=true" alt="logo" width="200">
  <br>
  GCBLUnit
  <br>
  <br>
</h1>

<h4 align="center">Simple Unit Testing for GnuCOBOL written in GnuCOBOL.</h4>

### Features
* Assertions
* Reporting
* Continuous Integration
* No mainframe required
* GnuCOBOL Docker

```bash
$ cobc -x -debug gcblunit.cbl tests/intrinsic/* --job='equals-test notequals-test'
GCBLUnit 0.22.1  by Olegs Kunicins and contributors.

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

```bash
$ cobc -x gcblunit.cbl --job=-h
GCBLUnit 0.22.1  by Olegs Kunicins and contributors.

Usage:                                                                          
  cobc -x -debug gcblunit.cbl first-test.cbl [next-test.cbl] --job='first-test [next-test]'         
  cobc -x -debug gcblunit.cbl --job=Options                                     

Options:                                                                        
  -h|-help                 Print this help                                      
  -v|--version             Print the version                                    
```

### Writing Tests
The examples you may find in the `tests` directory.

At the moment two assertions are implemented:
 - assert-equals
 - assert-notequals

### Continuous Integration
COBOLUnit returns an exit-code of the execusion that is usually enough for CI pipelines.

### Alternatives
GCBLUnit primarily focuses on Unit Testing - isolated GnuCOBOL functions and programs with an input and output.

Nonetheless, you may try two alternatives as well:
 - `cobol-unit-test` - a paragraph-level Unit Testing framework, written by Dave Nicolette, hosted on [GitHub](https://github.com/neopragma/cobol-unit-test/wiki).
 - `COBOLUnit` - a full-featured Unit Testing framework for COBOL, written by Hervé Vaujour, hosted on [Google Sites](https://sites.google.com/site/cobolunit/). Not updated since 2010.

### TODO
 - Stop upon the first exception `--stop-on-exception`
 - Stop upon the first failed test `--stop-on-failed`
 - Stop upon the first skipped test `--stop-on-skipped`
 - Report in JUnit XML format
 - Assertion `assert-greater`
 - Assertion `assert-less`
 - Setup
 - Teardown
 - Auto-discovery of the tests in the compilation group

Your contribution is always welcome!
