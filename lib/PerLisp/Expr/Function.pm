package PerLisp::Expr::Function;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(name => sub { die 'no name set' });
__PACKAGE__->attr(body => sub { die 'no body set' });

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    #return 'Function: ' . $self->body->to_string;
    return 'Function[ ' . $self->name . ']';
}

sub to_simple {
    my $self = shift;
    return {function => {
        name => $self->name,
        body => $self->body->to_simple
    };
}

sub apply {
    my ($self, $args) = @_;
    die 'TODO';
}

1;
__END__
