package PerLisp::Parser;
use PerLisp::Mo;

use experimental 'switch';

use PerLisp::Expr::Number;
use PerLisp::Expr::String;
use PerLisp::Expr::Symbol;
use PerLisp::Expr::List;

sub parse {
    my ($self, $tokens) = @_;

    # expression container
    my @exprs;

    # one after another
    push @exprs, $self->expr($tokens) until $tokens->is_empty;

    # return expressions
    return @exprs;
}

sub expr {
    my ($self, $tokens) = @_;
    my $token = $tokens->next_token;

    # what is it?
    given ($token->name) {

        # atom
        return $self->number($token) when 'NUMBER';
        return $self->string($token) when 'STRING';
        return $self->symbol($token) when 'SYMBOL';

        # quoted expression
        return $self->quote($tokens) when 'QUOTE';

        # call
        return $self->list($tokens)  when 'LIST_START';

        # parser error
        default {
            die "Expression can't start with $_ token: "
                . $token->to_string . "\n";
        }
    }
}

sub number {
    my ($self, $token) = @_;
    return PerLisp::Expr::Number->new(
        value => $token->attribute,
    );
}

sub string {
    my ($self, $token) = @_;
    return PerLisp::Expr::String->new(
        value => $token->attribute,
    );
}

sub symbol {
    my ($self, $token) = @_;
    return PerLisp::Expr::Symbol->new(
        name => $token->attribute,
    );
}

sub quote {
    my ($self, $tokens) = @_;

    # build quote symbol
    my $quote_symbol = PerLisp::Expr::Symbol->new(
        name => 'quote'
    );

    # parse next expression
    my $quoted_expr = $self->expr($tokens);

    # and hide it in a quote operator call
    return PerLisp::Expr::List->new(
        exprs => [$quote_symbol, $quoted_expr],
    );
}

sub list {
    my ($self, $tokens) = @_;

    # scan till end of list
    my @exprs = ();
    while ($tokens->look_ahead and $tokens->look_ahead->name ne 'LIST_END') {
        push @exprs, $self->expr($tokens);
    }
    $tokens->next_token; # consume LIST_END
    return PerLisp::Expr::List->new(exprs => \@exprs);
}

1;
__END__
