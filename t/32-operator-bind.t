#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use PerLisp;

my $pl = PerLisp->new;
$pl->init;

# try to bind a number
$pl->eval('(bind foo 42)');
is($pl->context->get('foo')->to_simple, 42, 'foo set right');

# try to re-bind foo
eval { $pl->eval('(bind foo 17)') };
is($@, "Symbol foo already bound.\n", 'foo already defined error message');
is($pl->context->get('foo')->to_simple, 42, 'foo set right');

# call bind with the wrong argument count
eval { $pl->eval('(bind quux)') };
is($@, "bind needs exactly two arguments.\n", 'right error message');

__END__
