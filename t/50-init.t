#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 29;

use FindBin '$Bin';
use PerLisp;
use PerLisp::Expr::Boolean;

my $pl = PerLisp->new->init;

# true and false symbols
is($pl->eval('(= true (= 1 1))')->to_string, 'true', 'true symbol');
is($pl->eval('(= false (= 1 2))')->to_string, 'true', 'false symbol');

# c[ad]d*r helpers
$pl->eval("(bind to-ten '(1 2 3 4 5 6 7 8 9 10))");
is($pl->eval('(cadr to-ten)')->to_string, 2, 'cadr');
is($pl->eval('(caddr to-ten)')->to_string, 3, 'caddr');
is($pl->eval('(cadddr to-ten)')->to_string, 4, 'cadddr');
is_deeply(
    $pl->eval('(cddr to-ten)')->to_simple,
    [ 3 .. 10 ],
    'cddr',
);
is_deeply(
    $pl->eval('(cdddr to-ten)')->to_simple,
    [ 4 .. 10 ],
    'cdddr',
);

# map
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
is($pl->eval("(quote? ''a)")->to_string, 'true', 'quote?');
is($pl->eval("(quote? 42)")->to_string, 'false', 'quote?');
is($pl->eval("(function? map)")->to_string, 'true', 'function?');
is($pl->eval("(function? 'a)")->to_string, 'false', 'function?');
is($pl->eval("(operator? cons)")->to_string, 'true', 'operator?');
is($pl->eval("(operator? 'a)")->to_string, 'false', 'operator?');

__END__
