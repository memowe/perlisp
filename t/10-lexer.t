#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 10;

use_ok('PerLisp::Lexer');
my $lexer = PerLisp::Lexer->new;

sub lex {
    my $string = shift;
    return $lexer->lex($string)->to_string;
}

# simple tokens
is(lex('('), "CALL_START\n", 'CALL_START');
is(lex(')'), "CALL_END\n", 'CALL_END');
is(lex("'"), "QUOTE\n", 'QUOTE');

# tokens with attributes
is(lex('42'), "NUMBER(42)\n", 'NUMBER');
is(lex('"hello !§$ € Føø"'), "STRING(hello !§\$ € Føø)\n", 'STRING');
is(lex('ÄBCDEFG_HI'), "SYMBOL(ÄBCDEFG_HI)\n", 'SYMBOL');

# complex token streams
is(
    lex("\n\n(   bind\n a \"a\"   )   \n "),
    "CALL_START\nSYMBOL(bind)\nSYMBOL(a)\nSTRING(a)\nCALL_END\n",
    '(bind a "a")',
);
is(
    lex("
        (defin (fak n)
            (cond (= n 0) 1
                (* n (fak (- n 1)))))
    "),
    "CALL_START\nSYMBOL(defin)\nCALL_START\nSYMBOL(fak)\nSYMBOL(n)\n"
    . "CALL_END\nCALL_START\nSYMBOL(cond)\nCALL_START\nSYMBOL(=)\nSYMBOL(n)\n"
    . "NUMBER(0)\nCALL_END\nNUMBER(1)\nCALL_START\nSYMBOL(*)\nSYMBOL(n)\n"
    . "CALL_START\nSYMBOL(fak)\nCALL_START\nSYMBOL(-)\nSYMBOL(n)\nNUMBER(1)\n"
    . "CALL_END\nCALL_END\nCALL_END\nCALL_END\nCALL_END\n",
    'factorial',
);

# bullshit
is(
    lex("))) bÜll \"s)\"it(   )"),
    "CALL_END\nCALL_END\nCALL_END\nSYMBOL(bÜll)\nSTRING(s))\n"
    . "SYMBOL(it)\nCALL_START\nCALL_END\n",
    'bullshit',
);

__END__
