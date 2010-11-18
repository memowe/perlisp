package PerLisp::Parser;
use base 'PerLisp::Base';

use strict;
use warnings;
use feature 'switch';

use PerLisp::Expr::Number;
use PerLisp::Expr::String;
use PerLisp::Expr::Symbol;
use PerLisp::Expr::QuoteExpr;
use PerLisp::Expr::Call;

sub parse {
    my ($self, $tokens) = @_;
    return $self->expr($tokens);
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
        return $self->call($tokens)  when 'CALL_START';

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
        value => $token->attr,
    );
}

sub string {
    my ($self, $token) = @_;
    return PerLisp::Expr::String->new(
        value => $token->attr,
    );
}

sub symbol {
    my ($self, $token) = @_;
    return PerLisp::Expr::Symbol->new(
        name => $token->attr,
    );
}

sub quote {
    my ($self, $tokens) = @_;
    return PerLisp::Expr::QuoteExpr->new(
        expr => $self->expr($tokens),
    );
}

sub call {
    my ($self, $tokens) = @_;

    # scan till end of list
    my @exprs = ();
    while ($tokens->look_ahead and $tokens->look_ahead->name ne 'CALL_END') {
        push @exprs, $self->expr($tokens);
    }
    $tokens->next_token; # consume CALL_END
    return PerLisp::Expr::Call->new(exprs => \@exprs);
}

1;
__END__
