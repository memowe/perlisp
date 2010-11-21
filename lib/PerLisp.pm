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
use PerLisp::Init;

__PACKAGE__->attr(context => sub { PerLisp::Context->new });
__PACKAGE__->attr(lexer   => sub { PerLisp::Lexer->new });
__PACKAGE__->attr(parser  => sub { PerLisp::Parser->new });

# REPL handles
__PACKAGE__->attr(input  => sub {IO::Handle->new->fdopen(fileno(STDIN),'r')});
__PACKAGE__->attr(output => sub {IO::Handle->new->fdopen(fileno(STDOUT),'w')});

# set operators
sub init {
    my $self = shift;

    # fresh context
    $self->context(PerLisp::Context->new);

    # here may be dragons
    no strict 'refs';

    # load basic operators
    my @long_names = qw(
        bind_name bound
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
        plus minus mult div pow mod less_than greater_than
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

    # load operator: load perlisp files
    $self->context->set(load => PerLisp::Expr::Operator->new(
        name => 'load',
        code => sub {
            my ($context, $filename_expr) = @_;

            # eval filename expression
            my $filename = $filename_expr->eval($context);

            # string check
            die 'Filename needs to be a string: ' . $filename->to_string . "\n"
                unless $filename->isa('PerLisp::Expr::String');
            my $fn = $filename->value;

            # existance and readability check
            die "File isn't readable: $fn.\n" unless -e -r $fn;

            # slurp + eval
            my $perlisp = slurp $fn;
            $self->eval($perlisp);

            # return nothing
            return;
        },
    ));

    # init definitions
    $self->eval($PerLisp::Init::definitions);

    # chaining
    return $self;
}

sub eval {
    my ($self, $string) = @_;

    # lex
    my $token_stream = $self->lexer->lex($string);

    # parse
    my @exprs = $self->parser->parse($token_stream);

    # eval
    my @values = map { $_->eval($self->context) } @exprs;

    # return
    return wantarray ? @values : shift @values;
}

sub read_eval_print_loop {
    my $self = shift;

    # read until EOD
    while (defined( my $line = $self->input->getline )) {

        # quit
        last if $line =~ /^(q(uit)?|bye|die|eod)$/i;

        # try to eval and print
        eval {
            my @values = $self->eval($line, $self->context);
            $self->output->print($_->to_string . "\n") for @values;
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

=head1 NAME

PerLisp

=head1 VERSION

0.1

=head1 SYNOPSIS

    use PerLisp;
    my $pl = PerLisp->new;  # create interpreter
    $pl->init;              # load operators and convenience functions
    print $pl->eval('(+ 17 25)')->to_string; # "42"

=head1 ABSTRACT

This is a simple statically scoped Lisp interpreter. During the lecture
"Structure and Interpretation of Programming Languages", held by Achim Clausing
(WWU Münster, Germany), I needed to try out diffent things, so I wrote this.

See the file README.md in the PerLisp distribution for a quick start guide.

=head1 API

=head2 ATTRIBUTES

=head3 context

A C<PerLisp::Context> object. The main "namespace".

=head3 lexer

A C<PerLisp::Lexer> object. The Lisp lexer.

=head3 parser

A C<PerLisp::Parser> object. The Lisp parser.

=head3 input

The input filehandle for the read eval print loop. STDIN by default.

=head3 output

The output filehandle for the read eval print loop. STDOUT by default.

=head2 METHODS

=head3 new

The constructor. Set other values for the attributes via hashref or a hashy
list. In most cases the default values work just fine.

=head3 init

Sets default operators and some convenience functions. Returns the interpreter
object, so you can chain the method calls:

    my $perlisp = PerLisp->new->init;

=head3 eval

Evals Lisp code as a string. In list context, it returns a list of all resulting
PerLisp expression objects. In scalar context, it returns the first.

You can stringify PerLisp expressions with the C<to_string> method. The
C<to_simple> method will return a simplified perl data structure and is mostly
used for testing and easy introspection with L<Data::Dumper>.

=head3 read_eval_print_loop

Creates some kind of a PerLisp shell.

=head1 AUTHOR, LICENSE, BUGS

Copyright (c) 2010 Mirko Westermeier, <mirko@westermeier.de>

This software is released under the MIT license (view MIT-LICENSE for details).

If you found a bug, please contact me via mail or github. You can also use
github's issue tracker. Please provide (failing) tests for your bugs, patches
or feature requests.
