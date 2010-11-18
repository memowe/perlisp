package PerLisp::Expr::List;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(exprs => sub { [] });

sub car {
    my $self = shift;
    return $self->exprs->[0];
}

sub cdr {
    my $self  = shift;
    my @exprs = @{$self->exprs};
    shift @exprs; # drop the car
    return PerLisp::Expr::List->new(exprs => \@exprs);
}

sub eval {
    my ($self, $context) = @_;

    # copy exprs
    my @exprs = @{$self->exprs};
    return unless @exprs; # empty list

    # get function expression and arguments
    my $fn_expr = $self->car;
    my @args    = @{$self->cdr->exprs};

    # eval function expression
    my $function = $fn_expr->eval($context);

    # check applyability (duck typing)
    die $fn_expr->to_string . " can't be applied.\n"
        unless $function->can('apply');

    # apply
    return $function->apply(\@args);
}

sub to_string {
    my $self = shift;
    my @expr_strings = map { $_->to_string } @{$self->exprs};
    return '(' . join(' ' => @expr_strings) . ')';
}

sub to_simple {
    my $self = shift;
    return unless @{$self->exprs};
    return [ map { $_->to_simple } @{$self->exprs} ];
}

1;
__END__
