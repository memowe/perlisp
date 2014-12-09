package PerLisp::Expr::Symbol;
use PerLisp::Mo;

extends 'PerLisp::Expr';

has 'name';

sub eval {
    my ($self, $context) = @_;
    return $context->get($self->name);
}

sub to_string {
    my $self = shift;
    return $self->name;
}

sub to_string_bound {
    my ($self, $context) = @_;

    # bound?
    return $self->eval($context)->to_string_bound($context)
        if $context->bound($self->name);

    # unbound
    return $self->to_string;
}

sub to_simple {
    my $self = shift;
    return $self->name;
}

sub to_simple_bound {
    my ($self, $context) = @_;

    # bound?
    return $self->eval($context)->to_simple_bound($context)
        if $context->bound($self->name);

    # unbound
    return $self->to_simple;
}

1;
__END__
