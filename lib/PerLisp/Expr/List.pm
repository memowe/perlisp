package PerLisp::Expr::List;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr('car');
__PACKAGE__->attr(cdr => sub { PerLisp::Expr::List->new });

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;

    # empty list
    return "()\n" unless defined $self->car;

    # list has at least one element
    my $car = $self->car->to_string;
    my $cdr = $self->cdr->to_string;
    chomp for $car, $cdr;
    return "($car $cdr)\n";
}

sub to_simple {
    my $self = shift;

    # empty list
    return undef unless defined $self->car;

    # list has at least one element
    return {
        car => $self->car->to_simple,
        cdr => $self->cdr->to_simple
    };
}

1;
__END__
