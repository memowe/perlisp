#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 9;

use PerLisp;

my $pl = PerLisp->new;
$pl->init;

# simple function construction
my $fun = $pl->eval('(lambda (x) (* x x))');
isa_ok($fun, 'PerLisp::Expr::Function', 'lambda value');
is_deeply($fun->params, ['x'], 'right parameter "list"');
is_deeply($fun->body->to_simple, [qw(* x x)], 'right body');
is_deeply($fun->context, $pl->context, 'right context');

# simple function application
$pl->context->set(square => $fun);
my $val = $pl->eval('(square 3)');
is_deeply($val->to_simple, 9, 'application simplification');

# define test
$pl->eval('(define (pair x) (list x x))');
$fun = $pl->context->get('pair');
isa_ok($fun, 'PerLisp::Expr::Function', '"define"d function');
is_deeply($pl->eval('(pair 6)')->to_simple, [6, 6], 'simplification');

# closure
$pl->eval('(define (add-n n) (lambda (x) (+ n x)))');
my $add_2 = $pl->eval('(add-n 2)');
isa_ok($add_2, 'PerLisp::Expr::Function', 'closure');
$pl->context->set('add-2' => $add_2);
is($pl->eval('(add-2 3)')->to_simple, 5, 'closure application simplification');

__END__
