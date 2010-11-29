#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 59;

use PerLisp;
use PerLisp::Expr::Boolean;

my $pl = PerLisp->new->init;

# true and false symbols
is($pl->eval('(= true (= 1 1))')->to_string, 'true', 'true symbol');
is($pl->eval('(= false (= 1 2))')->to_string, 'true', 'false symbol');

# equal aliases
is($pl->eval('(eq 42 (+ 17 25))')->to_string, 'true', 'eq function');
is($pl->eval('(eq 42 17)')->to_string, 'false', 'eq function');
is($pl->eval('(neq 42 (+ 17 25))')->to_string, 'false', 'neq function');
is($pl->eval('(neq 42 17)')->to_string, 'true', 'neq function');
is($pl->eval('(!= 42 (+ 17 25))')->to_string, 'false', '!= function');
is($pl->eval('(!= 42 17)')->to_string, 'true', '!= function');

# empty list helper
is($pl->eval("(nil? '())")->to_string, 'true', 'nil? helper');
is($pl->eval("(nil? '(foo bar))")->to_string, 'false', 'nil? helper');
is($pl->eval("(nil? 42)")->to_string, 'false', 'nil? helper');

# type helpers
is($pl->eval("(number? 42)")->to_string, 'true', 'number?');
is($pl->eval("(number? 'a)")->to_string, 'false', 'number?');
is($pl->eval("(string? \"foo\")")->to_string, 'true', 'string?');
is($pl->eval("(string? 'a)")->to_string, 'false', 'string?');
is($pl->eval("(symbol? 'a)")->to_string, 'true', 'symbol?');
is($pl->eval("(symbol? 42)")->to_string, 'false', 'symbol?');
is($pl->eval("(boolean? false)")->to_string, 'true', 'boolean?');
is($pl->eval("(boolean? 'a)")->to_string, 'false', 'boolean?');
is($pl->eval("(list? '(1 2 3))")->to_string, 'true', 'list?');
is($pl->eval("(list? 'a)")->to_string, 'false', 'list?');
is($pl->eval("(function? map)")->to_string, 'true', 'function?');
is($pl->eval("(function? 'a)")->to_string, 'false', 'function?');
is($pl->eval("(operator? cons)")->to_string, 'true', 'operator?');
is($pl->eval("(operator? 'a)")->to_string, 'false', 'operator?');

# c[ad]d*r helpers: length 2
$pl->eval("(bind cl1 '((a b) c d))");
is($pl->eval('(caar cl1)')->to_string, 'a', 'caar');
is($pl->eval('(cadr cl1)')->to_string, 'c', 'cadr');
is($pl->eval('(cdar cl1)')->to_string, '(b)', 'cdar');
is($pl->eval('(cddr cl1)')->to_string, '(d)', 'cddr');

# c[ad]d*r helpers: length 3
$pl->eval("(bind cl2 '(((a b) c d) (e f) g h))");
is($pl->eval('(caaar cl2)')->to_string, 'a', 'caaar');
is($pl->eval('(caadr cl2)')->to_string, 'e', 'caadr');
is($pl->eval('(cadar cl2)')->to_string, 'c', 'cadar');
is($pl->eval('(caddr cl2)')->to_string, 'g', 'caddr');
is($pl->eval('(cdaar cl2)')->to_string, '(b)', 'cdaar');
is($pl->eval('(cdadr cl2)')->to_string, '(f)', 'cdadr');
is($pl->eval('(cddar cl2)')->to_string, '(d)', 'cddar');
is($pl->eval('(cdddr cl2)')->to_string, '(h)', 'cdddr');

# c[ad]d*r helpers: length 4
$pl->eval("(bind cl3 '((((a b) c d) (e f) g h) ((i j) k l) (m n) o p))");
is($pl->eval('(caaaar cl3)')->to_string, 'a', 'caaaar');
is($pl->eval('(caaadr cl3)')->to_string, 'i', 'caaadr');
is($pl->eval('(caadar cl3)')->to_string, 'e', 'caadar');
is($pl->eval('(caaddr cl3)')->to_string, 'm', 'caaddr');
is($pl->eval('(cadaar cl3)')->to_string, 'c', 'cadaar');
is($pl->eval('(cadadr cl3)')->to_string, 'k', 'cadadr');
is($pl->eval('(caddar cl3)')->to_string, 'g', 'caddar');
is($pl->eval('(cadddr cl3)')->to_string, 'o', 'cadddr');
is($pl->eval('(cdaaar cl3)')->to_string, '(b)', 'cdaaar');
is($pl->eval('(cdaadr cl3)')->to_string, '(j)', 'cdaadr');
is($pl->eval('(cdadar cl3)')->to_string, '(f)', 'cdadar');
is($pl->eval('(cdaddr cl3)')->to_string, '(n)', 'cdaddr');
is($pl->eval('(cddaar cl3)')->to_string, '(d)', 'cddaar');
is($pl->eval('(cddadr cl3)')->to_string, '(l)', 'cddadr');
is($pl->eval('(cdddar cl3)')->to_string, '(h)', 'cdddar');
is($pl->eval('(cddddr cl3)')->to_string, '(p)', 'cddddr');

# map
$pl->eval("(bind to-ten '(1 2 3 4 5 6 7 8 9 10))");
$pl->eval('(define (add-1 x) (+ x 1))');
is_deeply(
    $pl->eval('(map add-1 to-ten)')->to_simple,
    [ 2 .. 11 ],
    'map',
);

# filter
is_deeply(
    $pl->eval('(filter (lambda (n) (= (% n 2) 0)) to-ten)')->to_simple,
    [ 2, 4, 6, 8, 10 ],
    'filter',
);

# reduce: sum
$pl->eval('(define (sum l) (reduce + l 0))');
is($pl->eval("(sum '(1 -1))")->to_string, 0, 'reduce: sum');
is($pl->eval('(sum to-ten)')->to_string, 55, 'reduce: sum');

# reduce: product
$pl->eval('(define (product l) (reduce * l 1))');
is($pl->eval("(product '(0 1 2 3 42))")->to_string, 0, 'reduce: product');
is($pl->eval('(product to-ten)')->to_string, 3628800, 'reduce: product');

__END__
