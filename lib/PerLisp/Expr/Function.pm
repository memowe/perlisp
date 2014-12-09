package PerLisp::Expr::Function;
use PerLisp::Mo qw(default required);

extends 'PerLisp::Expr';

has params  => [];
has body    => (required => 1);
has context => (required => 1);
has tracer  => (); # a tracer code ref

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

sub to_string_bound {
    my ($self, $context) = @_;
    my $param_string = '(' . join(' ' => @{$self->params}) . ')';
    my $body_string  = $self->body->to_string_bound($context);
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

sub to_simple_bound {
    my ($self, $context) = @_;
    return {function => {
        params  => $self->params,
        body    => $self->body->to_simple_bound($context),
        context => $self->context->binds,
    }};
}

sub apply {
    my ($self, $context, $args) = @_;

    # check arity: die if too many arguments
    my $arity = @{$self->params};
    die "can't apply: too many arguments.\n"
        if @$args > $arity;

    # try to match arguments and parameters to create local param bindings
    my %binds;
    my @params = @{$self->params};
    foreach my $arg (@$args) {

        # eval argument
        my $val = $arg->eval($context);

        # bind
        my $param       = shift @params;
        $binds{$param}  = $val;
    }

    # static scope
    $context = $self->context;

    # specialize context
    my $local_context = $context->specialize(\%binds);

    # remaining parameters? return a curried version
    if (@params) {
        return PerLisp::Expr::Function->new(
            params  => \@params,
            body    => $self->body,
            context => $local_context,
            tracer  => $self->tracer,
        );
    }

    # exact match: eval the body with new bindings
    return $self->body->eval($local_context);
}

1;
__END__
