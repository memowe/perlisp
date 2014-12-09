package PerLisp::Expr::String;
use PerLisp::Mo;

extends 'PerLisp::Expr';

has 'value';

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    return '"' . $self->value . '"';
}

sub to_string_bound {
    my ($self, $context) = @_;
    return $self->to_string;
}

sub to_simple {
    my $self = shift;
    return '"' . $self->value . '"';
}

sub to_simple_bound {
    my ($self, $context) = @_;
    return $self->to_simple;
}

1;
__END__
