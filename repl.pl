#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/lib";

use PerLisp;

print "Hi, this is PerLisp.\n";
PerLisp->new->read_eval_print_loop;
print "Done.\n";

__END__
