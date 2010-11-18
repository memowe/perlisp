package PerLisp;
use base 'PerLisp::Base';

our $VERSION = '0.1';

use strict;
use warnings;

use IO::Handle;
use PerLisp::Lexer;
use PerLisp::Parser;
use PerLisp::Context;
use PerLisp::Expr::List;
use PerLisp::Expr::Operator;
use PerLisp::Expr::Function;

# RE tools
__PACKAGE__->attr(lexer  => sub { PerLisp::Lexer->new });
__PACKAGE__->attr(parser => sub { PerLisp::Parser->new });

# P tools
__PACKAGE__->attr(input  => sub {IO::Handle->new->fdopen(fileno(STDIN),'r')});
__PACKAGE__->attr(output => sub {IO::Handle->new->fdopen(fileno(STDOUT),'w')});

# E tools
__PACKAGE__->attr(context => sub { PerLisp::Context->new });

# set operators
sub init {
    my $self = shift;

    # bind (eval 2nd argument)
    $self->context->set(bind => PerLisp::Expr::Operator->new(
        name => 'bind',
        code => sub {
            my $context = shift;
            die "bind needs exactly two arguments.\n" unless @_ == 2;
            my ($symbol, $expr) = @_;
            my $value = $expr->eval($context);
            $context->set($symbol->name => $value);
            return $value;
        },
    ));

    # cons (eval both arguments)
    $self->context->set(cons => PerLisp::Expr::Operator->new(
        name => 'cons',
        code => sub {
            my ($context, $car_expr, $cdr_expr) = @_;
            my $list = PerLisp::Expr::List->new;

            if ($car_expr) {
                push @{$list->exprs}, $car_expr->eval($context);
                
                if ($cdr_expr) {
                    my $cdr = $cdr_expr->eval($context);
                    die "cdr must be a list.\n"
                        unless $cdr->isa('PerLisp::Expr::List');
                    push @{$list->exprs}, @{$cdr->exprs};
                }
            }
            return $list;
        },
    ));

    # list (eval all arguments)
    $self->context->set(list => PerLisp::Expr::Operator->new(
        name => 'list',
        code => sub {
            my ($context, @elm_exprs) = @_;
            my @exprs = map { $_->eval($context) } @elm_exprs;
            return PerLisp::Expr::List->new(
                exprs => \@exprs,
            );
        },
    ));

    # car (eval argument)
    $self->context->set(car => PerLisp::Expr::Operator->new(
        name => 'car',
        code => sub {
            my ($context, $list_expr) = @_;
            my $list = $list_expr->eval($context);
            die 'car can\'t be applied on non list ' . $list->to_string . "\n"
                unless $list->isa('PerLisp::Expr::List');
            return $list->car;
        },
    ));

    # cdr (eval argument)
    $self->context->set(cdr => PerLisp::Expr::Operator->new(
        name => 'cdr',
        code => sub {
            my ($context, $list_expr) = @_;
            my $list = $list_expr->eval($context);
            die 'cdr can\'t be applied on non list ' . $list->to_string
                unless $list->isa('PerLisp::Expr::List');
            return $list->cdr;
        },
    ));

    # lambda (eval nothing)
    $self->context->set(lambda => PerLisp::Expr::Operator->new(
        name => 'lambda',
        code => sub {
            my ($context, $param_list, $body) = @_;
            die "lambda needs a parameter list.\n"
                unless $param_list->isa('PerLisp::Expr::List');
            my @param_names;
            foreach my $expr (@{$param_list->exprs}) {
                die 'only symbols allowed in parameter lists: '
                    . $expr->to_string . "\n"
                    unless $expr->isa('PerLisp::Expr::Symbol');
                push @param_names, $expr->name;
            }
            return PerLisp::Expr::Function->new(
                params  => \@param_names,
                body    => $body,
                context => $context,
            );
        },
    ));
}

sub eval {
    my ($self, $string) = @_;

    # lex
    my $token_stream = $self->lexer->lex($string);

    # parse
    my $expr = $self->parser->parse($token_stream);

    # eval
    return $expr->eval($self->context);
}


sub read_eval_print_loop {
    my $self = shift;
    $self->init;

    # read until EOD
    while (defined( my $line = $self->input->getline )) {

        # quit
        last if $line =~ /^(q(uit)?|bye|die|eod)$/i;

        # try to eval and print
        eval {
            my $value = $self->eval($line, $self->context);
            $self->output->print($value->to_string . "\n");
        };

        # catch errors
        if ($@) {
            my $msg = $@;
            $self->output->print("Error: $msg");
        }
    }
}

1;
__END__
