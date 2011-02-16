package PerLisp::Token;
use PerLisp::Base -base;

has name => sub { die 'all tokens need a name' };
has 'attribute';

sub to_string {
    my $self = shift;
    return $self->name unless defined $self->attribute;
    return $self->name . '(' . $self->attribute . ')';
}

1;
__END__
