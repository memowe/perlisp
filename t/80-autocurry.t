#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 11;

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

# build sum and product of lists from curried reduce
$pl->eval('(bind sum (reduce + 0))');
is($pl->eval('(sum (list 9 10 11 12))')->to_simple, 42, 'right sum');
$pl->eval('(bind prod (reduce * 1))');
is($pl->eval('(prod (list 7 2 3))')->to_simple, 42, 'right product');

# build odd-filter from curried filter
$pl->eval('(bind odd-filter (filter (lambda (x) (= 1 (% x 2)))))');
is_deeply($pl->eval('(odd-filter (list 17 42 37 666 999))')->to_simple,
    [17, 37, 999], 'right filtered list'
);

# just to be sure: too many arguments
eval { $pl->eval('(mult 1 2 3)'); die 'no exception thrown'; };
is($@, "can't apply: too many arguments.\n", 'right error message');

__END__
