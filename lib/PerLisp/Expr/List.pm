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

    # call trace
    my $ctrace = '(' . join(' ' => map { $_->to_string } $fn_expr, @args) . ')';
    $function->tracer->("\tCall\t$ctrace")
        if $function->tracer;

    # apply
    my $ret_val = $function->apply($context, \@args);

    # return trace
    my $ret_val_str = ref($ret_val) ? $ret_val->to_string : $ret_val // '';
    my $rtrace = $ret_val_str . " from $ctrace";
    $function->tracer->("\tReturn\t$rtrace")
        if $function->tracer;

    # done
    return $ret_val;
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
