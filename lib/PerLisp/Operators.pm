package PerLisp::Operators;
# not a class!

use strict;
use warnings;

use PerLisp::Expr::List;
use PerLisp::Expr::Function;

sub bind { # eval only second argument
    die "bind needs exactly two arguments.\n" unless @_ == 3;
    my ($context, $symbol, $expr) = @_;

    # eval
    my $value = $expr->eval($context);

    # bind
    $context->set($symbol->name => $value);

    # return the value
    return $value;
}

sub cons { # eval both arguments
    my ($context, $car_expr, $cdr_expr) = @_;

    # construct a list
    my $list = PerLisp::Expr::List->new;

    # car handling
    if ($car_expr) {
        push @{$list->exprs}, $car_expr->eval($context);
        
        # cdr handling
        if ($cdr_expr) {
            my $cdr = $cdr_expr->eval($context);
            die "cdr must be a list.\n"
                unless $cdr->isa('PerLisp::Expr::List');
            push @{$list->exprs}, @{$cdr->exprs};
        }
    }

    # return the new list
    return $list;
}

sub list { # eval all arguments
    my ($context, @elm_exprs) = @_;

    # eval all list element expressions
    my @exprs = map { $_->eval($context) } @elm_exprs;

    # build the list
    return PerLisp::Expr::List->new(
        exprs => \@exprs,
    );
}

sub car { # eval the argument
    my ($context, $list_expr) = @_;

    # eval the list expression
    my $list = $list_expr->eval($context);

    # check listness
    die 'car can\'t be applied on non list ' . $list->to_string . "\n"
        unless $list->isa('PerLisp::Expr::List');

    # return the car
    return $list->car;
}

sub cdr { # eval the argument
    my ($context, $list_expr) = @_;

    # eval the list expression
    my $list = $list_expr->eval($context);

    # check listness
    die 'cdr can\'t be applied on non list ' . $list->to_string
        unless $list->isa('PerLisp::Expr::List');

    # return the cdr
    return $list->cdr;
}

sub lambda { # eval nothing
    my ($context, $param_list, $body) = @_;

    # check parameter list
    die "lambda needs a parameter list.\n"
        unless $param_list->isa('PerLisp::Expr::List');

    # create parameter "list" from parameter list symbols
    my @param_names;
    foreach my $expr (@{$param_list->exprs}) {
        die 'only symbols allowed in parameter lists: '
            . $expr->to_string . "\n"
            unless $expr->isa('PerLisp::Expr::Symbol');
        push @param_names, $expr->name;
    }

    # construct a function
    return PerLisp::Expr::Function->new(
        params  => \@param_names,
        body    => $body,
        context => $context,
    );
}

1;
__END__
