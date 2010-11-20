package PerLisp::Operators::Arithmetic;
# not a class but a package

use strict;
use warnings;

use PerLisp::Expr::Number;
use PerLisp::Expr::Boolean;

our %short_name = (
    plus            => '+',
    minus           => '-',
    mult            => '*',
    div             => '/',
    pow             => '^',
    mod             => '%',
    less_than       => '<',
    greater_than    => '>',
);

sub plus {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # add
    return PerLisp::Expr::Number->new(
        value => $a->value + $b->value,
    );
}

sub minus {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # subtract
    return PerLisp::Expr::Number->new(
        value => $a->value - $b->value,
    );
}

sub mult {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # multiply
    return PerLisp::Expr::Number->new(
        value => $a->value * $b->value,
    );
}

sub div {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # divide
    return PerLisp::Expr::Number->new(
        value => $a->value / $b->value,
    );
}

sub pow {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # power
    return PerLisp::Expr::Number->new(
        value => $a->value ** $b->value,
    );
}

sub mod {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # modulo
    return PerLisp::Expr::Number->new(
        value => $a->value % $b->value,
    );
}

sub less_than {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # less than
    return $a->value < $b->value ?
            $PerLisp::Expr::Boolean::TRUE
        :   $PerLisp::Expr::Boolean::FALSE;
}

sub greater_than {
    my ($context, $a_expr, $b_expr) = @_;

    # eval
    my $a = $a_expr->eval($context);
    my $b = $b_expr->eval($context);

    # less than
    return $a->value > $b->value ?
            $PerLisp::Expr::Boolean::TRUE
        :   $PerLisp::Expr::Boolean::FALSE;
}

1;
__END__
