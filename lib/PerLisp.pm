package PerLisp;
use base 'PerLisp::Base';

our $VERSION = '0.1';

use strict;
use warnings;

use IO::Handle;
use FindBin '$Bin';
use File::Slurp 'slurp';
use PerLisp::Operators;
use PerLisp::Operators::Arithmetic;
use PerLisp::Lexer;
use PerLisp::Parser;
use PerLisp::Context;
use PerLisp::Expr::Operator;

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
    my $init_filename = "$Bin/init.perlisp";
    if (-e -r $init_filename) {

        # slurp
        my $perlisp = slurp $init_filename;

        # eval
        $self->eval_multiple_expressions($perlisp);
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
