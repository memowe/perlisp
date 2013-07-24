package PerLisp::Expr::Operator;
use Mo 'required';

extends 'PerLisp::Expr';

has name => (required => 1);
has code => (required => 1);

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
    my ($self, $context, $args) = @_;
    return $self->code->($context, @$args);
}

1;
__END__
