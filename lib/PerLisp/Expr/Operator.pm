package PerLisp::Expr::Operator;
use PerLisp::Mo qw(required default);

extends 'PerLisp::Expr';

has name    => (required => 1);
has code    => (required => 1);
has tracer  => (); # a tracer code ref

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    return $self->name;
}

sub to_string_bound {
    my ($self, $context) = @_;
    return $self->to_string;
}

sub to_simple {
    my $self = shift;
    return {operator => $self->name};
}

sub to_simple_bound {
    my ($self, $context) = @_;
    return $self->to_simple;
}

sub apply {
    my ($self, $context, $args) = @_;
    return $self->code->($context, @$args);
}

1;
__END__
