#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 36;

use PerLisp;

my $pl = PerLisp->new->init;

# empty list
my $list = $pl->eval('(list)');
isa_ok($list, 'PerLisp::Expr::List', 'empty list');
is_deeply($list->to_simple, [], 'empty list simplification');

# n element list
foreach my $n (1 .. 17) {
    my $numbers = join ' ' => 1 .. $n;
    $pl->eval("(bind n$n (list $numbers))");
    $list = $pl->context->get("n$n");
    isa_ok($list, 'PerLisp::Expr::List', "$n element list");
    is_deeply(
        $list->to_simple,
        [ map { $_ } 1 .. $n ],
        "$n element list simplification",
    );
}

__END__
