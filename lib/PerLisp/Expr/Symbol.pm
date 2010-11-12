package PerLisp::Expr::Symbol;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr('name');

sub to_string {
    my $self = shift;
    return $self->name;
}

sub to_simple {
    my $self = shift;
    return $self->name;
}

1;
__END__
