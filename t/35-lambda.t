#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;

use PerLisp;

my $pl = PerLisp->new;
$pl->init;

# simple function construction
my $fun = $pl->eval('(lambda (x) (list x x))');
isa_ok($fun, 'PerLisp::Expr::Function', 'lambda value');
is_deeply($fun->params, ['x'], 'right parameter "list"');
is_deeply($fun->body->to_simple, [qw(list x x)], 'right body');
is_deeply($fun->context, $pl->context, 'right context');

# simple function application
$pl->context->set(pair => $fun);
my $val = $pl->eval('(pair 3)');
is_deeply($val->to_simple, [3, 3], 'application simplification');

__END__
