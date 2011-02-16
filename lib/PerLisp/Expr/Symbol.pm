package PerLisp::Expr::Symbol;
use PerLisp::Base 'PerLisp::Expr';

has 'name';

sub eval {
    my ($self, $context) = @_;
    return $context->get($self->name);
}

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
