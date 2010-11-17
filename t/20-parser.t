#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 19;

use PerLisp::Lexer;
use_ok('PerLisp::Parser');

my $lexer  = PerLisp::Lexer->new;
my $parser = PerLisp::Parser->new;

sub parse {
    my $string = shift;
    my $tokens = $lexer->lex($string);
    return $parser->parse($tokens);
}

# simple expressions
isa_ok(parse('42'), 'PerLisp::Expr::Number', 'parsed number');
is(parse('42')->to_string, "42\n", 'right Number');

isa_ok(parse('"Hi"'), 'PerLisp::Expr::String', 'parsed string');
is(parse('"Hi"')->to_string, "\"Hi\"\n", 'right String');

isa_ok(parse('hØ'), 'PerLisp::Expr::Symbol', 'parsed symbol');
is(parse('hØ')->to_string, "hØ\n", 'right Symbol');

# "complex" expression
my $tree = parse('(a "b" 42)');
isa_ok($tree, 'PerLisp::Expr::Call', 'parsed a call');
my @exprs = @{$tree->exprs};
isa_ok($exprs[0], 'PerLisp::Expr::Symbol', 'first parsed call elem');
isa_ok($exprs[1], 'PerLisp::Expr::String', 'second parsed call elem');
isa_ok($exprs[2], 'PerLisp::Expr::Number', 'third parsed call elem');
is_deeply($tree->to_simple, [qw(a "b" 42)], 'right Call');
is($tree->to_string, '(a "b" 42)', 'right Call stringification');

# quoted "complex" expression
$tree = parse('\'(a "b" 42)');
isa_ok($tree, 'PerLisp::Expr::QuoteExpr', 'parsed quoted call');
is_deeply($tree->to_simple, {quoted => [qw(a "b" 42)]}, 'right \'Call');
is($tree->to_string, '(a "b" 42)', 'right \'Call stringification');

# complex expression
$tree = parse("
    (defin (fak n)
        (cond (= n 0) 1
            (* n (fak (- n 1)))))
"),
isa_ok($tree, 'PerLisp::Expr::Call', 'parsed complex expression');
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

__END__
