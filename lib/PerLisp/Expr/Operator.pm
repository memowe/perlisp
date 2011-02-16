package PerLisp::Expr::Operator;
use PerLisp::Base 'PerLisp::Expr';

has name => sub { die 'no name set' };
has code => sub { die 'no code set' };

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
