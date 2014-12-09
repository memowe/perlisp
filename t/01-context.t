#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 22;

use PerLisp::Context;
use PerLisp::Expr::Number;

my $context = PerLisp::Context->new;

# try to get foo (undefined)
ok(! $context->bound('foo'), 'foo unbound');
my $value = eval { $context->get('foo') };
ok(! defined $value, 'foo undefined');
is($@, "Couldn't find foo in context.\n", 'foo undefined error message');

# bind a number
ok(! $context->bound('foo'), 'foo unbound');
$context->set(foo => PerLisp::Expr::Number->new(value => 42));
ok($context->bound('foo'), 'foo bound');
my $number = $context->get('foo');
isa_ok($number, 'PerLisp::Expr::Number', 'foo');
is($number->to_simple, 42, 'foo set right');

# try to redefine foo
ok($context->bound('foo'), 'foo already bound');
eval { $context->set(foo => PerLisp::Expr::Number->new(value => 17)) };
is($context->get('foo')->to_simple, 42, 'foo has the old value');
is($@, "Symbol foo already bound.\n", 'foo redefined error message');

# specialize
my $context2 = $context->specialize({
    bar => PerLisp::Expr::Number->new(value => 17),
});
ok($context2->bound('foo'), 'foo bound in new context');
ok($context2->bound('bar'), 'bar bound in new context');
ok(! $context->bound('bar'), 'bar unbound in new context');
is($context2->get('foo')->to_simple, 42, 'right foo value');
is($context2->get('bar')->to_simple, 17, 'right bar value');

# specialize with overwrite
my $context3 = $context2->specialize({
    foo => PerLisp::Expr::Number->new(value => 37),
    baz => PerLisp::Expr::Number->new(value => 17),
});
ok($context3->bound('foo'), 'foo bound in new context');
ok($context3->bound('bar'), 'bar bound in new context');
ok($context3->bound('baz'), 'baz bound in new context');
ok(! $context2->bound('baz'), 'baz unbound in old new context');
is($context3->get('foo')->to_simple, 37, 'right foo value');
is($context3->get('bar')->to_simple, 17, 'right bar value');
is($context3->get('baz')->to_simple, 17, 'right baz value');

__END__
