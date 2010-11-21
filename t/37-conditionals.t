#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 36;

use PerLisp;
use PerLisp::Expr::Boolean;

my $pl = PerLisp->new;
$pl->init;

# empty list predicate
is($pl->eval("(nil? '())")->to_string, 'true', 'empty list');
is($pl->eval("(nil? '(a b c))")->to_string, 'false', 'non-empty list');

# equal: same object
$pl->eval("(bind a '(1 2 3))");
$pl->eval('(bind b (car a))');
is($pl->eval('(= b (car a))')->to_string, 'true', 'same object');
is($pl->eval('(= b a)')->to_string, 'false', 'different objects');

# equal: boolean
$pl->context->set(bool1 => PerLisp::Expr::Boolean->new(value => 1));
$pl->context->set(bool2 => $PerLisp::Expr::Boolean::TRUE);
$pl->context->set(bool3 => $PerLisp::Expr::Boolean::FALSE);
is($pl->eval('(= bool1 bool2)')->to_string, 'true', 'same boolean');
is($pl->eval('(= bool1 bool3)')->to_string, 'false', 'different booleans');

# equal: two numbers
is($pl->eval('(= 42 (+ 17 25))')->to_string, 'true', 'same number');
is($pl->eval('(= 42 37)')->to_string, 'false', 'different numbers');

# equal: two strings
is($pl->eval('(= "foo" "foo")')->to_string, 'true', 'same string');
is($pl->eval('(= "foo" "bar")')->to_string, 'false', 'different strings');

# equal: two symbols
is($pl->eval("(= 'foo 'foo)")->to_string, 'true', 'same symbol');
is($pl->eval("(= 'foo 'bar)")->to_string, 'false', 'different symbols');

# equal: two quoted expressions
is($pl->eval("(= ''(1 3) ''(1 3))")->to_string, 'true', 'same quote');
is($pl->eval("(= ''(1 3) ''(1 4))")->to_string, 'false', 'different quotes');

# equal: two lists
is($pl->eval("(= a '(1 2 3))")->to_string, 'true', 'same list');
is($pl->eval("(= a '(1 2 4))")->to_string, 'false', 'different lists');
is($pl->eval("(= a '(1 2 3 4))")->to_string, 'false', 'different lists');

# logical and
is($pl->eval('(and (= 1 1) bool2)')->to_string, 'true', 'true and true');
is($pl->eval('(and (= 1 1) bool3)')->to_string, 'false', 'true and false');
is($pl->eval('(and (= 1 2) bool2)')->to_string, 'false', 'false and true');
is($pl->eval('(and (= 1 2) bool3)')->to_string, 'false', 'false and false');

# logical and: sce
my $and = eval { $pl->eval('(and (= 1 1) xnorfzt)') };
is($@, "Couldn't find xnorfzt in context.\n", 'true and undef');
is($pl->eval('(and (= 1 2) xnorfzt)')->to_string, 'false', 'false and undef');

# logical or
is($pl->eval('(or (= 1 1) bool2)')->to_string, 'true', 'true or true');
is($pl->eval('(or (= 1 1) bool3)')->to_string, 'true', 'true or false');
is($pl->eval('(or (= 1 2) bool2)')->to_string, 'true', 'false or true');
is($pl->eval('(or (= 1 2) bool3)')->to_string, 'false', 'false or false');

# logical or: sce
my $or = eval { $pl->eval('(or (= 1 2) xnorfzt)') };
is($@, "Couldn't find xnorfzt in context.\n", 'false or undef');
is($pl->eval('(or (= 1 1) xnorfzt)')->to_string, 'true', 'true or undef');

# logical not
is($pl->eval('(not (= 1 1))')->to_string, 'false', 'not true');
is($pl->eval('(not (= 1 2))')->to_string, 'true', 'not false');

# basic conditional expression
is($pl->eval('(cond (= 1 1) 42 17)')->to_string, 42, 'cond: then');
is($pl->eval('(cond (= 1 2) 42 17)')->to_string, 17, 'cond: else');

# complex conditional expression
$pl->eval("
    (define (double x)
        (cond
            (= x 1) 2
            (= x 2) 4
            'many))
");
is($pl->eval('(double 1)')->to_string, 2, 'complex cond: first'); 
is($pl->eval('(double 2)')->to_string, 4, 'complex cond: second'); 
is($pl->eval('(double 3)')->to_string, 'many', 'complex cond: else'); 

__END__
