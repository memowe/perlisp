#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 8;

use PerLisp;

my $pl = PerLisp->new->init;

# simple two parameter function
my $fun = $pl->eval('(lambda (a b) (* a b))');
isa_ok($fun, 'PerLisp::Expr::Function', 'lambda value');
is_deeply($fun->params, ['a', 'b'], 'right parameter list');

# bind the function to a name
$pl->context->set(mult => $fun);
my $curry_fun = $pl->eval('(mult 6)');
isa_ok($curry_fun, 'PerLisp::Expr::Function', 'lambda value');
is_deeply($curry_fun->params, ['b'], 'right parameter list');

# bind the curried function to a name
$pl->context->set(mult6 => $curry_fun);
my $val = $pl->eval('(mult6 7)');
isa_ok($val, 'PerLisp::Expr::Number', 'number value');
is($val->to_simple, 42, 'right number value');

# directly apply
is($pl->eval('(eq (mult 17 42) ((mult 17) 42))')->to_simple, 'true', 'equal');

# just to be sure: too many arguments
eval { $pl->eval('(mult 1 2 3)'); die 'no exception thrown'; };
is($@, "can't apply: too many arguments.\n", 'right error message');

__END__
