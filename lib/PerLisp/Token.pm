package PerLisp::Token;
use base 'PerLisp::Base';

use strict;
use warnings;

__PACKAGE__->attr(name => sub { die "all tokens need a name" });
__PACKAGE__->attr('attr');

sub to_string {
    my $self = shift;
    return $self->name unless defined $self->attr;
    return $self->name . '(' . $self->attr . ')';
}

1;
__END__
