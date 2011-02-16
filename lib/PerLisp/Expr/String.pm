package PerLisp::Expr::String;
use base 'PerLisp::Expr';

__PACKAGE__->attr('value');

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
