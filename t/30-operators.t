#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 'no_plan';

use_ok('PerLisp');

my $pl = PerLisp->new;
$pl->init;

my @operators = qw(bind cons list car cdr);

# all operators bound
is_deeply(
    [ sort keys %{$pl->context->to_hash} ],
    [ sort @operators ],
    'bound right operators',
);

# right stringifications
foreach my $operator (@operators) {
    is(
        $pl->context->get($operator)->to_string,
        "Operator[$operator]",
        "right operator $operator stringification",
    );
}

__END__
