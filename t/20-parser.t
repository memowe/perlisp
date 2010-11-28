#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 29;

use PerLisp::Lexer;
use_ok('PerLisp::Parser');

my $lexer  = PerLisp::Lexer->new;
my $parser = PerLisp::Parser->new;

sub parse {
    my $string = shift;
    my $tokens = $lexer->lex($string);
    my @exprs  = $parser->parse($tokens);
    return shift @exprs;
}

# simple expressions
isa_ok(parse('42'), 'PerLisp::Expr::Number', 'parsed number');
is(parse('42')->to_string, '42', 'right Number');

isa_ok(parse('"Hi"'), 'PerLisp::Expr::String', 'parsed string');
is(parse('"Hi"')->to_string, '"Hi"', 'right String');

isa_ok(parse('hØ'), 'PerLisp::Expr::Symbol', 'parsed symbol');
is(parse('hØ')->to_string, 'hØ', 'right Symbol');

# "complex" expression
my $tree = parse('(a "b" 42)');
isa_ok($tree, 'PerLisp::Expr::List', 'parsed a list');
my @exprs = @{$tree->exprs};
isa_ok($exprs[0], 'PerLisp::Expr::Symbol', 'first parsed list elem');
isa_ok($exprs[1], 'PerLisp::Expr::String', 'second parsed list elem');
isa_ok($exprs[2], 'PerLisp::Expr::Number', 'third parsed list elem');
is_deeply($tree->to_simple, [qw(a "b" 42)], 'right List');
is($tree->to_string, '(a "b" 42)', 'right List stringification');

# quoted "complex" expression
$tree = parse('\'(a "b" 42)');
isa_ok($tree, 'PerLisp::Expr::List', 'parsed quoted list');
isa_ok($tree->exprs->[0], 'PerLisp::Expr::Symbol', 'first list item');
is($tree->exprs->[0]->name, 'quote', 'parsed quoted list');
is_deeply($tree->to_simple, ['quote', [qw(a "b" 42)]], 'right \'List');
is($tree->to_string, '(quote (a "b" 42))', 'right \'List stringification');

# double quoted expression
$tree = parse("\'\'42");
isa_ok($tree, 'PerLisp::Expr::List', 'parsed double quoted 42');
isa_ok($tree->exprs->[1], 'PerLisp::Expr::List', 'nested quoted 42');
isa_ok($tree->exprs->[1]->exprs->[1], 'PerLisp::Expr::Number', '42');
is($tree->exprs->[1]->exprs->[1]->value, 42, 'right double quoted number');
is_deeply($tree->to_simple, ['quote', [quote => 42]], '\'\' simplification');

# complex expression
$tree = parse("
    (defin (fak n)
        (cond (= n 0) 1
            (* n (fak (- n 1)))))
"),
isa_ok($tree, 'PerLisp::Expr::List', 'parsed complex expression');
is_deeply(
    $tree->to_simple,
    ['defin', [qw(fak n)], ['cond', [qw(= n 0)], 1,
        ['*', 'n', ['fak', [qw(- n 1)]]]
    ]],
    'right parsed complex expression',
);
is(
    $tree->to_string,
    '(defin (fak n) (cond (= n 0) 1 (* n (fak (- n 1)))))',
    'right parsed complex expression stringification'
);

# multiple expressions
my $tokens = $lexer->lex('42 (1 2 3)');
@exprs  = $parser->parse($tokens);
is($exprs[0]->to_string, 42, 'multiple expressions');
is_deeply($exprs[1]->to_string, '(1 2 3)', 'multiple expressions');

# more complex multiple expressions
$tokens = $lexer->lex('
    ; "the" true
    (bind true (= 1 1))
    ; "tre" false
    (bind false (not true))
');
is_deeply(
    [ map { $_->to_simple } $parser->parse($tokens) ],
    [ ['bind', 'true', [qw(= 1 1)]], ['bind', 'false', [qw(not true)]] ],
    'complex multiple expressions',
);

__END__
