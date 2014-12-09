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
    if ($context->bound($self->name)) {

        # get value
        my $val = $self->eval($context);

        # isa Function? no replacement!
        return $self->name
            if $val->isa('PerLisp::Expr::Function');

        # no Function? to_string_bound!
        return $val->to_string_bound($context);
    }

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
    if ($context->bound($self->name)) {

        # get value
        my $val = $self->eval($context);

        # isa Function? no replacement!
        return $self->name
            if $val->isa('PerLisp::Expr::Function');

        # no Function? to_simple_bound!
        return $val->to_simple_bound($context);
    }

    # unbound
    return $self->to_simple;
}

1;
__END__
