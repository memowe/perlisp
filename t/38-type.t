#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

use PerLisp;
use PerLisp::Expr::Boolean;

my $pl = PerLisp->new->init;

# type properties
my $type = $pl->eval('(type 42)');
isa_ok($type, 'PerLisp::Expr::Symbol', 'type return value');
is($type->name, 'Number', 'right type symbol name');
is($pl->eval('(= (type 42) (type 17))')->to_string, 'true', 'same types');
$type = $pl->eval('(type (type 42))');
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of type return value');
is($type->name, 'Symbol', 'right type of type symbol name');

# type of number
is($pl->eval("(= (type 42) 'Number)")->to_string, 'true', 'Number');

# type of string
is($pl->eval("(= (type \"hi\") 'String)")->to_string, 'true', 'String');

# type of boolean
is($pl->eval("(= (type true) 'Boolean)")->to_string, 'true', 'Boolean');

# type of symbol
is($pl->eval("(= (type 'foo) 'Symbol)")->to_string, 'true', 'Symbol');

# type of list
is($pl->eval("(= (type '(foo)) 'List)")->to_string, 'true', 'List');

# type of quoted expression
is($pl->eval("(= (type ''42) 'QuoteExpr)")->to_string, 'true', 'QuoteExpr');

# type of operator
is($pl->eval("(= (type cons) 'Operator)")->to_string, 'true', 'Operator');

# type of function
is($pl->eval("(= (type map) 'Function)")->to_string, 'true', 'Function');

__END__
