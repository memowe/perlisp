package PerLisp::Expr::Function;
use base 'PerLisp::Expr';

use strict;
use warnings;

__PACKAGE__->attr(params  => sub { [] });
__PACKAGE__->attr(body    => sub { die 'no body set' });
__PACKAGE__->attr(context => sub { die 'no context set' });

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    return 'Function';
}

sub to_simple {
    my $self = shift;
    return {function => {
        params  => $self->params,
        body    => $self->body->to_simple,
        context => $self->context->binds,
    }};
}

sub apply {
    my ($self, $context, $args) = @_;

    # check arity
    my $arity = @{$self->params};
    die "can't apply: $arity params expected.\n"
        unless @$args == $arity;

    # create local param bindings
    my %binds;
    $binds{$_} = shift @$args for @{$self->params};

    # static scope
    $context = $self->context;

    # specialize context
    my $local_context = $context->specialize(\%binds);

    # eval the body with new bindings
    return $self->body->eval($local_context);
}

1;
__END__
