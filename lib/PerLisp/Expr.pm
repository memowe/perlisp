package PerLisp::Expr;
use base 'PerLisp::Base';

use strict;
use warnings;

sub eval {
    my ($self, $context) = @_;
    die 'override!';
}

sub to_string { die 'override!' }

sub to_simple { die 'override!' }

1;
__END__