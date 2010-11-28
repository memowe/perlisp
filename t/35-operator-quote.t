#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use PerLisp;

my $pl = PerLisp->new->init;

# quoted empty list
$pl->eval("(bind qfoo '())");
my $list = $pl->eval('qfoo');
isa_ok($list, 'PerLisp::Expr::List', 'quoted empty list');
ok(! defined $list->to_simple, 'quoted empty list simplification');

# quoted complex list
$list = $pl->eval("'(foo bar (baz quux) 42)");
is_deeply(
    $list->to_simple,
    ['foo', 'bar', [qw(baz quux)], '42'],
    'complex quoted list simplification',
);

# explicit quote operator call
my $a = $pl->eval("'((foo 42) bar)");
my $b = $pl->eval('(quote ((foo 42) bar))');
is_deeply($a->to_simple, $b->to_simple, 'explicit quote operator call');

__END__
