package PerLisp::Expr::QuoteExpr;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr('expr');

sub to_string {
    my $self = shift;
    return $self->expr->to_string;
}

sub to_simple {
    my $self = shift;
    return {quoted => $self->expr->to_simple};
}

1;
__END__
