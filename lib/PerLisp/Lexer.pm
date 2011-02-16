package PerLisp::Lexer;
use PerLisp::Base -base;

use PerLisp::Token;
use PerLisp::TokenStream;

sub lex {
    my ($self, $string) = @_;

    # delete comments
    $string =~ s/;.*//g;

    # cleanup
    $string =~ s/\s+/ /g;
    $string =~ s/^ //;

    # lex
    my $tokens = PerLisp::TokenStream->new;
    while ($string ne '') {

        # opening brace
        $string =~ s/^\( ?// and do {
            $tokens->add(PerLisp::Token->new(name => 'LIST_START'));
            next; 
        };

        # closing brace
        $string =~ s/^\) ?// and do {
            $tokens->add(PerLisp::Token->new(name => 'LIST_END'));
            next;
        };

        # quote
        $string =~ s/^'// and do {
            $tokens->add(PerLisp::Token->new(name => 'QUOTE'));
            next;
        };

        # number
        $string =~ s/^(-?\d+(\.\d+)?) ?// and do {
            $tokens->add(PerLisp::Token->new(
                name        => 'NUMBER',
                attribute   => $1,
            ));
            next;
        };

        # string
        $string =~ s/^"([^"]+)" ?// and do {
            $tokens->add(PerLisp::Token->new(
                name        => 'STRING',
                attribute   => $1,
            ));
            next;
        };

        # symbol
        $string =~ s/([^\s()]+) ?// and do {
            $tokens->add(PerLisp::Token->new(
                name        => 'SYMBOL',
                attribute   => $1,
            ));
            next;
        };

        # lexer error
        die "couldn't lex: >$string<\n";
    }

    return $tokens;
}

1;
__END__
