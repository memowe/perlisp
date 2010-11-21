#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

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

__END__
