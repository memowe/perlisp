package PerLisp::Expr::Number;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr('value');

sub to_string {
    my $self = shift;
    return $self->value;
}

sub to_simple {
    my $self = shift;
    return $self->value;
}

1;
__END__
