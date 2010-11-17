#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 15;

use PerLisp::Context;
use PerLisp::Expr::Number;

my $context = PerLisp::Context->new;

# try to get foo (undefined)
my $value = eval { $context->get('foo') };
ok(! defined $value, 'foo undefined');
is($@, "Couldn't find foo in context.\n", 'foo undefined error message');

# bind a number
$context->set(foo => PerLisp::Expr::Number->new(value => 42));
is($context->get('foo')->to_simple, 42, 'foo set right');

# try to redefine foo
eval { $context->set(foo => PerLisp::Expr::Number->new(value => 17)) };
is($context->get('foo')->to_simple, 42, 'foo has the old value');
is($@, "Symbol foo already bound.\n", 'foo redefined error message');

# push new values
$context->push({
    bar => PerLisp::Expr::Number->new(value => 17),
    baz => PerLisp::Expr::Number->new(value => 37),
});
is($context->get('foo')->to_simple, 42, 'foo set right');
is($context->get('bar')->to_simple, 17, 'bar pushed right');
is($context->get('baz')->to_simple, 37, 'baz pushed right');

# pop
$context->pop;
is($context->get('foo')->to_simple, 42, 'foo set right');
$value = eval { $context->get('bar') };
ok(! defined $value, 'bar undefined after pop');
is($@, "Couldn't find bar in context.\n", 'bar undefined error message');

# pop too often
eval { $context->pop };
is($context->get('foo')->to_simple, 42, 'foo set right');
like($@, qr/Couldn't pop/, 'pop impossible error message');

# push values that are already set
eval { $context->push({
    foo => PerLisp::Expr::Number->new(value => 17),
})};
is($context->get('foo')->to_simple, 42, 'foo set right');
is($@, "Symbol foo already bound.\n", 'foo redefined error message');

__END__
