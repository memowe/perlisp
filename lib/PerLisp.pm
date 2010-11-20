package PerLisp;
use base 'PerLisp::Base';

our $VERSION = '0.1';

use strict;
use warnings;

use IO::Handle;
use File::Slurp 'slurp';
use PerLisp::Operators;
use PerLisp::Operators::Arithmetic;
use PerLisp::Lexer;
use PerLisp::Parser;
use PerLisp::Context;
use PerLisp::Expr::Operator;

__PACKAGE__->attr(context => sub { PerLisp::Context->new });
__PACKAGE__->attr(lexer   => sub { PerLisp::Lexer->new });
__PACKAGE__->attr(parser  => sub { PerLisp::Parser->new });

# REPL handles
__PACKAGE__->attr(input  => sub {IO::Handle->new->fdopen(fileno(STDIN),'r')});
__PACKAGE__->attr(output => sub {IO::Handle->new->fdopen(fileno(STDOUT),'w')});

# init file path
__PACKAGE__->attr('initfile');

# set operators
sub init {
    my $self = shift;

    # fresh context
    $self->context(PerLisp::Context->new);

    # here may be dragons
    no strict 'refs';

    # load basic operators
    my @long_names = qw(
        bind_name
        cons list car cdr
        lambda define
        cond is_nil equal
        logical_and logical_or logical_not
    );
    my %short_name = %PerLisp::Operators::short_name;
    foreach my $name (@long_names) {

        # redirect
        my $short    = $short_name{$name};
        my $operator = PerLisp::Expr::Operator->new(
            name => $short,
            code => sub {
                *{"PerLisp::Operators::$name"}->(@_)
            },
        );

        # save to context
        $self->context->set($short => $operator);
    }

    # load arithmetic operators
    @long_names = qw(
        plus minus mult div pow mod
    );
    %short_name = %PerLisp::Operators::Arithmetic::short_name;
    foreach my $name (@long_names) {

        # redirect
        my $short    = $short_name{$name};
        my $operator = PerLisp::Expr::Operator->new(
            name => $short,
            code => sub {
                *{"PerLisp::Operators::Arithmetic::$name"}->(@_)
            },
        );

        # save to context
        $self->context->set($short => $operator);
    }

    # init file
    if ($self->initfile) {
        if (-e -r $self->initfile) {

            # slurp
            my $perlisp = slurp $self->initfile;

            # eval
            $self->eval_multiple_expressions($perlisp);
        }
        else {
            die "Couldn't read init file " . $self->initfile . "\n";
        }
    }
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

sub eval_multiple_expressions {
    my ($self, $string) = @_;

    # comments
    $string =~ s/;.*//g;

    # cleanup
    $string =~ s/\r\n/\n/g;

    # split: expressions separated by double newlines
    my @strings = split /\n{2}/ => $string;

    # eval
    return [ map { $self->eval($_) } @strings ];
}

1;
__END__
