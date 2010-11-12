package PerLisp;
use base 'PerLisp::Base';

our $VERSION = '0.1';

use strict;
use warnings;

use IO::Handle;

__PACKAGE__->attr(lexer         => sub { PerLisp::Lexer->new });
__PACKAGE__->attr(parser        => sub { PerLisp::Parser->new });
__PACKAGE__->attr(interpreter   => sub { PerLisp::Interpreter->new });
__PACKAGE__->attr(input => sub {IO::Handle->new->fdopen(fileno(STDIN),'r')});
__PACKAGE__->attr(output => sub {IO::Handle->new->fdopen(fileno(STDOUT),'w')});

sub read_eval_print_loop {
    my $self   = shift;

    # read until EOD
    while (defined( my $line = $self->input->getline )) {
        chomp $line;

        # lex
        my $token_stream = $self->lexer->lex($line);

        # parse
        my $expr_tree = $self->parser->parse($token_stream);

        # eval
        my $value = $self->interpreter->eval($expr_tree);

        # print
        $self->output->print($value->to_string);
    }
}

1;
__END__
