#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use PerLisp;
use FindBin '$Bin';

my $pl = PerLisp->new->init;

my $filename = "$Bin/test.perlisp";
$pl->eval("(load \"$filename\")");
is($pl->eval('(xnorfzt-square 3)')->to_simple, 9, 'square from file');
is($pl->eval('(xnorfzt-cube 3)')->to_simple, 27, 'cube from file');

__END__
