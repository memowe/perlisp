#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 40;

use PerLisp;
use PerLisp::Expr::Boolean;

my $pl = PerLisp->new->init;

# prepare some bound stuff
$pl->eval('(bind a 17)');
ok($pl->context->bound('a'), '"a" is bound');

# boolean
my $boolean = $pl->eval('(= 42 42)');
isa_ok($boolean, 'PerLisp::Expr::Boolean', 'the value');
is($boolean->to_string, 'true', 'Boolean->to_string');
is($boolean->to_string_bound($pl->context), 'true', 'Boolean->to_string_bound');
is($boolean->to_simple, 'true', 'Boolean->to_simple');
is($boolean->to_simple_bound($pl->context), 'true', 'Boolean->to_simple_bound');

# number
my $number = $pl->eval('37');
isa_ok($number, 'PerLisp::Expr::Number', 'the value');
is($number->to_string, '37', 'Number->to_string');
is($number->to_string_bound($pl->context), '37', 'Number->to_string_bound');
is($number->to_simple, '37', 'Number->to_simple');
is($number->to_simple_bound($pl->context), '37', 'Number->to_simple_bound');

# string
my $string = $pl->eval('"YOLO"');
isa_ok($string, 'PerLisp::Expr::String', 'the value');
is($string->to_string, '"YOLO"', 'String->to_string');
is($string->to_string_bound($pl->context), '"YOLO"', 'String->to_string_bound');
is($string->to_simple, '"YOLO"', 'String->to_simple');
is($string->to_simple_bound($pl->context), '"YOLO"', 'String->to_simple_bound');

# operator
my $operator = $pl->eval('*');
isa_ok($operator, 'PerLisp::Expr::Operator', 'the value');
is($operator->to_string, '*', 'Operator->to_string');
is($operator->to_string_bound($pl->context), '*', 'Operator->to_string_bound');
is_deeply($operator->to_simple, {operator => '*'},
    'Operator->to_simple'
);
is_deeply($operator->to_simple_bound($pl->context), {operator => '*'},
    'Operator->to_simple_bound'
);

# symbol
my $symbol = $pl->eval("'a");
isa_ok($symbol, 'PerLisp::Expr::Symbol', 'the value');
is($symbol->to_string, 'a', 'Symbol->to_string');
is($symbol->to_string_bound($pl->context), '17', 'Symbol->to_string_bound');
is($symbol->to_simple, 'a', 'Symbol->to_simple');
is($symbol->to_simple_bound($pl->context), '17', 'Symbol->to_simple_bound');

# list
my $list = $pl->eval("(list 37 'a (= 1 2))");
isa_ok($list, 'PerLisp::Expr::List', 'the value');
is($list->to_string, '(37 a false)', 'List->to_string');
is($list->to_string_bound($pl->context), '(37 17 false)',
    'List->to_string_bound'
);
is_deeply($list->to_simple, [qw(37 a false)], 'List->to_simple');
is_deeply($list->to_simple_bound($pl->context), [qw(37 17 false)],
    'List->to_simple_bound'
);

# function
my $function = $pl->eval('(lambda (x) (+ x a))');
isa_ok($function, 'PerLisp::Expr::Function', 'the value');
is($function->to_string, 'Function: (x) -> (+ x a)',
    'Function->to_string'
);
is($function->to_string_bound($pl->context), 'Function: (x) -> (+ x 17)',
    'Function->to_string_bound'
);
my $function_simple = $function->to_simple->{function};
is_deeply($function_simple->{params}, ['x'],
    'Function->simple params'
);
is_deeply($function_simple->{body}, [qw(+ x a)],
    'Function->simple body'
);
is($function_simple->{context}, $pl->context->binds,
    'Function->simple context'
);
my $function_sb = $function->to_simple_bound($pl->context)->{function};
is_deeply($function_sb->{params}, ['x'], 'Function->simple_bound params');
is_deeply($function_sb->{body}, [{operator => '+'}, 'x', 17],
    'Function->simple_bound body'
);
is($function_sb->{context}, $pl->context->binds,
    'Function->simple_bound context'
);

__END__
