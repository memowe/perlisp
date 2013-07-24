package PerLisp::Token;
use PerLisp::Mo 'required';

has name        => (required => 1);
has attribute   => ();

sub to_string {
    my $self = shift;
    return $self->name unless defined $self->attribute;
    return $self->name . '(' . $self->attribute . ')';
}

1;
__END__
