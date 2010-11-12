#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 10;

use PerLisp::Lexer;
use_ok('PerLisp::Lexer');
my $lexer = PerLisp::Lexer->new;

# simple tokens
is(
    $lexer->lex('(')->to_string,
    "LIST_START\n",
    'LIST_START',
);
is(
    $lexer->lex(')')->to_string,
    "LIST_END\n",
    'LIST_END',
);
is(
    $lexer->lex("'")->to_string,
    "QUOTE\n",
    'QUOTE',
);

# tokens with attributes
is(
    $lexer->lex('42')->to_string,
    "NUMBER(42)\n",
    'NUMBER',
);
is(
    $lexer->lex('"hello world !§$ € Føø"')->to_string,
    "STRING(hello world !§\$ € Føø)\n",
    'STRING',
);
is(
    $lexer->lex('ÄBCDEFG_HI')->to_string,
    "SYMBOL(ÄBCDEFG_HI)\n",
    'SYMBOL',
);

# complex token streams
is(
    $lexer->lex("\n\n(   bind\n a \"a\"   )   \n ")->to_string,
    "LIST_START\nSYMBOL(bind)\nSYMBOL(a)\nSTRING(a)\nLIST_END\n",
    '(bind a "a")',
);
is(
    $lexer->lex("
        (defin (fak n)
            (cond (= n 0) 1
                (* n (fak (- n 1)))))
    ")->to_string,
    "LIST_START\nSYMBOL(defin)\nLIST_START\nSYMBOL(fak)\nSYMBOL(n)\n"
    . "LIST_END\nLIST_START\nSYMBOL(cond)\nLIST_START\nSYMBOL(=)\nSYMBOL(n)\n"
    . "NUMBER(0)\nLIST_END\nNUMBER(1)\nLIST_START\nSYMBOL(*)\nSYMBOL(n)\n"
    . "LIST_START\nSYMBOL(fak)\nLIST_START\nSYMBOL(-)\nSYMBOL(n)\nNUMBER(1)\n"
    . "LIST_END\nLIST_END\nLIST_END\nLIST_END\nLIST_END\n",
    'factorial',
);

# bullshit
is(
    $lexer->lex("))) bÜll \"s)\"it(   )")->to_string,
    "LIST_END\nLIST_END\nLIST_END\nSYMBOL(bÜll)\nSTRING(s))\n"
    . "SYMBOL(it)\nLIST_START\nLIST_END\n",
    'bullshit',
);

__END__
