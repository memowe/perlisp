#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Slurp 'slurp';

# this test may be slow, so disable it by default
plan skip_all => 'set LISPLISP to enable this test (slow and deep recursion)'
    unless $ENV{LISPLISP};
plan tests => 4;

use PerLisp;
use FindBin '$Bin';

my $pl = PerLisp->new->init;

# load lisplisp
my $filename = "$Bin/lisplisp.perlisp";
$pl->eval("(load \"$filename\")");

# multiple expressions
my $exprs = '
    42
    (+ 17 25)
    (= 0 1)
    (cond (= 0 1) 17 42)
';
my $eval_exprs = "(lisp (quote ($exprs)) initial-context)";
my $values = $pl->eval($eval_exprs);
isa_ok($values, 'PerLisp::Expr::List', 'lisp value list');
is_deeply($values->to_string, '(42 42 false 42)', 'right lisp value list');

# load the lisplisp file
my $lisp = slurp $filename;

# lisp in lisp
$values = $pl->eval("(lisp (quote (
    $lisp
    (lisp (quote ($exprs)) initial-context)
)) initial-context)");
isa_ok($values, 'PerLisp::Expr::List', 'lisplisp value list');
is_deeply($values->to_string, '((42 42 false 42))', 'lisplisp value list');

__END__
