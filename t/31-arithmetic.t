#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 11;

use PerLisp;

my $pl = PerLisp->new->init;

# simple arithmetic operations
is($pl->eval('(+ 3 7)')->to_simple, 10, 'right sum');
is($pl->eval('(- 8 9)')->to_simple, -1, 'right subtraction');
is($pl->eval('(* 4 3)')->to_simple, 12, 'right product');
is($pl->eval('(/ 8 2)')->to_simple, 4, 'right division');
is($pl->eval('(^ 2 3)')->to_simple, 8, 'right power');
is($pl->eval('(% 8 3)')->to_simple, 2, 'right modulo');

# arithmetic predicates
is($pl->eval('(< 3 8)')->to_string, 'true', 'right less_than');
is($pl->eval('(< 8 3)')->to_string, 'false', 'right less_than');
is($pl->eval('(> 3 8)')->to_string, 'false', 'right greater_than');
is($pl->eval('(> 8 3)')->to_string, 'true', 'right greater_than');

# complex arithmetic operations
is(
    $pl->eval('(- (+ (- 37 (+ 17 20)) (^ 3 8)) (* 53 123))')->to_simple,
    42,
    'right complex arithmetic operation',
);

__END__
