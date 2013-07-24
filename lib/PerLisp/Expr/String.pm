package PerLisp::Expr::String;
use Mo;

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

sub to_simple {
    my $self = shift;
    return '"' . $self->value . '"';
}

1;
__END__
