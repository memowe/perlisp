package PerLisp::Expr::Function;
use PerLisp::Base 'PerLisp::Expr';

has params  => sub { [] };
has body    => sub { die 'no body set' };
has context => sub { die 'no context set' };

sub eval {
    my ($self, $context) = @_;
    return $self;
}

sub to_string {
    my $self = shift;
    my $param_string = '(' . join(' ' => @{$self->params}) . ')';
    my $body_string  = $self->body->to_string;
    return 'Function: ' . $param_string . ' -> ' . $body_string;
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
    foreach my $param (@{$self->params}) {
        
        # eval argument
        my $arg = shift @$args;
        my $val = $arg->eval($context);

        # bind
        $binds{$param} = $val;
    }

    # static scope
    $context = $self->context;

    # specialize context
    my $local_context = $context->specialize(\%binds);

    # eval the body with new bindings
    return $self->body->eval($local_context);
}

1;
__END__
