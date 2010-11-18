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
is(lex('('), "LIST_START\n", 'LIST_START');
is(lex(')'), "LIST_END\n", 'LIST_END');
is(lex("'"), "QUOTE\n", 'QUOTE');

# tokens with attributes
is(lex('42'), "NUMBER(42)\n", 'NUMBER');
is(lex('"hello !§$ € Føø"'), "STRING(hello !§\$ € Føø)\n", 'STRING');
is(lex('ÄBCDEFG_HI'), "SYMBOL(ÄBCDEFG_HI)\n", 'SYMBOL');

# complex token streams
is(
    lex("\n\n(   bind\n a \"a\"   )   \n "),
    "LIST_START\nSYMBOL(bind)\nSYMBOL(a)\nSTRING(a)\nLIST_END\n",
    '(bind a "a")',
);
is(
    lex("
        (defin (fak n)
            (cond (= n 0) 1
                (* n (fak (- n 1)))))
    "),
    "LIST_START\nSYMBOL(defin)\nLIST_START\nSYMBOL(fak)\nSYMBOL(n)\n"
    . "LIST_END\nLIST_START\nSYMBOL(cond)\nLIST_START\nSYMBOL(=)\nSYMBOL(n)\n"
    . "NUMBER(0)\nLIST_END\nNUMBER(1)\nLIST_START\nSYMBOL(*)\nSYMBOL(n)\n"
    . "LIST_START\nSYMBOL(fak)\nLIST_START\nSYMBOL(-)\nSYMBOL(n)\nNUMBER(1)\n"
    . "LIST_END\nLIST_END\nLIST_END\nLIST_END\nLIST_END\n",
    'factorial',
);

# bullshit
is(
    lex("))) bÜll \"s)\"it(   )"),
    "LIST_END\nLIST_END\nLIST_END\nSYMBOL(bÜll)\nSTRING(s))\n"
    . "SYMBOL(it)\nLIST_START\nLIST_END\n",
    'bullshit',
);

__END__
