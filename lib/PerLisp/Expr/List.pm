package PerLisp::Expr::List;
use PerLisp::Mo 'default';

extends 'PerLisp::Expr';

has exprs => [];

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

    # empty list
    return unless @{$self->exprs};

    # get function expression and arguments
    my $fn_expr = $self->car;
    my @args    = @{$self->cdr->exprs};

    # eval function expression
    my $function = $fn_expr->eval($context);

    # check apply-ability (duck typing)
    die $fn_expr->to_string . " can't be applied.\n"
        unless $function->can('apply');

    # apply
    return $function->apply($context, \@args);
}

sub to_string {
    my $self = shift;
    my @expr_strings = map { $_->to_string } @{$self->exprs};
    return '(' . join(' ' => @expr_strings) . ')';
}

sub to_string_bound {
    my ($self, $context) = @_;
    my @expr_strings = map { $_->to_string_bound($context) } @{$self->exprs};
    return '(' . join(' ' => @expr_strings) . ')';
}

sub to_simple {
    my $self = shift;
    return [ map { $_->to_simple } @{$self->exprs} ];
}

sub to_simple_bound {
    my ($self, $context) = @_;
    return [ map { $_->to_simple_bound($context) } @{$self->exprs} ];
}

1;
__END__
