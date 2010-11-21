#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 'no_plan';

use_ok('PerLisp');

my $pl = PerLisp->new;
$pl->init;

my @operators = qw(
    bind bound
    cons list car cdr
    lambda define
    cond nil? =
    and or not
    load
    + - * / ^ % < >
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
