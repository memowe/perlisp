package PerLisp::Expr::Call;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(exprs => sub { [] });

sub eval {
    my ($self, $context) = @_;

    # copy exprs
    my @exprs = @{$self->exprs};
    return unless @exprs; # empty list

    # get function and arguments
    my $fn_symbol = shift @exprs;
    my @args      = @exprs;

    # check symbolness
    die $fn_symbol->to_string . "isn't a symbol.\n"
        unless $fn_symbol->isa('PerLisp::Expr::Symbol');

    # get function
    my $fn_name  = $fn_symbol->name;
    my $function = $context->get($fn_name);

    # check applyability (duck typing)
    die $fn_name . " can't be applied: " . $function->to_string . "\n"
        unless $function->can('apply');

    # apply
    return $function->apply(\@args);
}

sub to_string {
    my $self = shift;
    my @expr_strings = map { $_->to_string } @{$self->exprs};
    chomp for @expr_strings;
    return '(' . join(' ' => @expr_strings) . ')';
}

sub to_simple {
    my $self = shift;
    return [ map { $_->to_simple } @{$self->exprs} ];
}

1;
__END__
