package PerLisp;
use PerLisp::Mo 'default';

our $VERSION = '0.1';

use IO::Handle;
use PerLisp::Operators;
use PerLisp::Operators::Arithmetic;
use PerLisp::Lexer;
use PerLisp::Parser;
use PerLisp::Context;
use PerLisp::Expr::Operator;
use PerLisp::Init;

has context => PerLisp::Context->new;
has lexer   => PerLisp::Lexer->new;
has parser  => PerLisp::Parser->new;

# REPL handles
has input   => IO::Handle->new->fdopen(fileno(STDIN), 'r');
has output  => IO::Handle->new->fdopen(fileno(STDOUT),'w');

# set operators
sub init {
    my $self = shift;

    # fresh context
    $self->context(PerLisp::Context->new);

    # here may be dragons
    no strict 'refs';

    # load basic operators
    my @long_names = qw(
        quote
        bind_name bound let
        cons list car cdr
        lambda define
        cond equal
        logical_and logical_or logical_not
        type
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

            # readability check
            die "File isn't readable: $fn.\n" unless -r $fn;

            # slurp + eval
            open my $fh, '<', $fn or die "couldn't open $fn: $!\n";
            my $perlisp = do { local $/; <$fh> };
            close $fh;
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
            for my $value ($self->eval($line, $self->context)) {
                my $output = $value->to_string_bound($self->context);
                $self->output->print("$output\n");
            }
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
