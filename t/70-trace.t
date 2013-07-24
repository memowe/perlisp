#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

use PerLisp;
use FindBin '$Bin';

my $pl = PerLisp->new->init;

my @traced;

$pl->tracer(sub { push @traced, shift });

$pl->eval('
    (define (fib n)
        (cond
            (= n 0) 1
            (= n 1) 1
            (+ (fib (- n 1)) (fib (- n 2)))))
');

# no trace
is($pl->eval('(fib 0)')->to_simple, 1, 'right fib(0) value');
is($pl->eval('(fib 1)')->to_simple, 1, 'right fib(1) value');
is($pl->eval('(fib 2)')->to_simple, 2, 'right fib(4) value');
is(scalar @traced, 0, 'no trace');

# multitrace
is($pl->eval('(trace + fib)'), 'traced: +, fib', 'trace on');
is($pl->eval('(fib 2)')->to_simple, 2, 'right traced fib(2) value');
is_deeply(\@traced, [
    "\tCall\t(fib 2)",
    "\tCall\t(+ (fib (- n 1)) (fib (- n 2)))",
    "\tCall\t(fib (- n 1))",
    "\tReturn\t1 from (fib (- n 1))",
    "\tCall\t(fib (- n 2))",
    "\tReturn\t1 from (fib (- n 2))",
    "\tReturn\t2 from (+ (fib (- n 1)) (fib (- n 2)))",
    "\tReturn\t2 from (fib 2)",
], 'right fib(2) and plus trace');

# untrace
@traced = ();
is($pl->eval('(untrace +)'), 'untraced: +', 'plus trace off');
is($pl->eval('(fib 3)')->to_simple, 3, 'right traced fib(3) value');
is_deeply(\@traced, [
    "\tCall\t(fib 3)",
    "\tCall\t(fib (- n 1))",
    "\tCall\t(fib (- n 1))",
    "\tReturn\t1 from (fib (- n 1))",
    "\tCall\t(fib (- n 2))",
    "\tReturn\t1 from (fib (- n 2))",
    "\tReturn\t2 from (fib (- n 1))",
    "\tCall\t(fib (- n 2))",
    "\tReturn\t1 from (fib (- n 2))",
    "\tReturn\t3 from (fib 3)",
], 'right fib(3) trace');

# no trace again
@traced = ();
is($pl->eval('(untrace fib)'), 'untraced: fib', 'fib trace off');
is($pl->eval('(fib 9)')->to_simple, 55, 'right fib(9) value');
is(scalar @traced, 0, 'no trace');

__END__
