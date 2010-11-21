#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;

use PerLisp;

my $pl = PerLisp->new;
$pl->init;

# eval simple multiple expressions
my @values = $pl->eval('37 (+ 17 25) (not (= 1 1))');
is($values[0]->to_simple, 37, 'first expression');
is($values[1]->to_simple, 42, 'second expression');
is($values[2]->to_string, 'false', 'third expression');

# eval more complex multiple expressions
$pl->eval('
    ; "the" true
    (bind t (= 1 1))
    ; "tre" false
    (bind f (not true))
');
is($pl->eval('(= t (= 2 2))')->to_string, 'true', 'first expression');
is($pl->eval('(= f (= 2 1))')->to_string, 'true', 'second expression');

__END__
