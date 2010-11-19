package PerLisp::Expr::Boolean;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(value => 0);

our $TRUE  = __PACKAGE__->new(value => 1);
our $FALSE = __PACKAGE__->new(value => 0);

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    return $self->value ? 'true' : 'false';
}

sub to_simple {
    my $self = shift;
    return $self->value ? 'true' : 'false';
}

1;
__END__
