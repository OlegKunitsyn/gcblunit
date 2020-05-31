FROM olegkunitsyn/gnucobol:3.1-dev
RUN mkdir /var/test
WORKDIR /var/test
COPY . .
RUN cobc -x -debug gcblunit.cbl tests/intrinsic/* --job='equals-test notequals-test'
