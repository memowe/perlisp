package PerLisp::Expr::Operator;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(name => sub { die 'no name set' });
__PACKAGE__->attr(code => sub { die 'no code set' });

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    return 'Operator[' . $self->name . ']';
}

sub to_simple {
    my $self = shift;
    return {operator => $self->name};
}

sub apply {
    my ($self, $args) = @_;
    return $self->code->(@$args);
}

1;
__END__
