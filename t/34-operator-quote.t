#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use PerLisp;

my $pl = PerLisp->new;
$pl->init;

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

__END__
