#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/lib";

use PerLisp;

my $pl = PerLisp->new(initfile => "$Bin/init.perlisp");
$pl->init;

my @bound_symbols = sort keys %{$pl->context->binds};

# read eval print loop
print "Hi, this is PerLisp.\n";
print 'Bound symbols: ' . join(', ' => @bound_symbols) . "\n";
$pl->read_eval_print_loop;
print "Done.\n";

__END__
