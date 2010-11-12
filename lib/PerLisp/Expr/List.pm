package PerLisp::Expr::List;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(exprs => sub { [] });

sub to_string {
    my $self = shift;
    my @expr_strings = map { $_->to_string } @{$self->exprs};
    return '(' . join(' ' => @expr_strings) . ')';
}

sub to_simple {
    my $self = shift;
    return [ map { $_->to_simple } @{$self->exprs} ];
}

1;
__END__
