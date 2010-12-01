#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 63;

use PerLisp;
use FindBin '$Bin';

my $pl = PerLisp->new->init;

# load lisplisp
my $filename = "$Bin/lisplisp.perlisp";
$pl->eval("(load \"$filename\")");

# context
is($pl->eval("(bind-get 'foo '())")->to_simple, 'UNBOUND', 'unbound symbol');
$pl->eval("(bind context (bind-set 'foo 42 '()))");
is($pl->eval("(bind-get 'foo context)")->to_simple, 42, 'bound symbol');

# eval simple expressions
is($pl->eval("(eval 42 '())")->to_simple, 42, 'eval Number');
is($pl->eval('(eval "foo" \'())')->to_simple, '"foo"', 'eval String');
is($pl->eval("(eval 'foo context)")->to_simple, 42, 'eval Symbol');

# eval quote
my $num = $pl->eval("(eval '(quote 42) '((quote (op quote))))");
isa_ok($num, 'PerLisp::Expr::Number', 'eval quoted number');
is($num->to_simple, 42, 'quoted Number');
my $sym = $pl->eval("(eval '(quote foo) '((quote (op quote))))");
isa_ok($sym, 'PerLisp::Expr::Symbol', 'eval quoted symbol');
is($sym->to_simple, 'foo', 'quoted Symbol');
my $add = $pl->eval("(eval '(quote (+ 17 25)) '((quote (op quote))))");
isa_ok($add, 'PerLisp::Expr::List', 'eval quoted List');
is($add->to_string, '(+ 17 25)', 'quoted List stringification');

# eval bind
my $bind = $pl->eval("(eval '(bind foo 42) '((bind (op bind))))");
isa_ok($bind, 'PerLisp::Expr::List', 'eval bind expression');
is($bind->to_string, '((foo 42) (bind (op bind)))', 'stringified bind');

# eval cond
$pl->eval("(bind cond_expr (quote
    (cond
        (= foo  0)  (quote null)
        (= foo 42)  (quote fortytwo)
        (quote other))
))");
foreach my $foo (0, 17, 42) {
    my $context = "((foo $foo) (= (op =)) (cond (op cond)) (quote (op quote)))";
    my $cond = $pl->eval("(eval cond_expr '$context)");
    isa_ok($cond, 'PerLisp::Expr::Symbol', 'eval cond expression');
    is(
        $cond->to_simple,
        {0 => 'null', 42 => 'fortytwo'}->{$foo} // 'other',
        #$foo == 0 ? 'null' : $foo == 42 ? 'fortytwo' : 'other',
        'right cond value'
    );
}

# eval simple lambda
my $function = $pl->eval("(eval '(lambda () 42) '((lambda (op lambda))))");
isa_ok($function, 'PerLisp::Expr::List', 'lambda return value');
is_deeply($function->to_simple, ['function', [], 42], 'lambda simplification');
my $return = $pl->eval("(eval '((lambda () 42)) '((lambda (op lambda))))");
isa_ok($return, 'PerLisp::Expr::Number', 'function return value');
is($return->to_simple, 42, 'right function return value');

# eval more complex lambda (dynamic scope)
$function = $pl->eval("(eval (quote
    (lambda (x y)
        (* (* x y) foo))
) '((lambda (op lambda))))");
isa_ok($function, 'PerLisp::Expr::List', 'lambda return value');
my $f_str = $function->to_string;
is_deeply($f_str, '(function (x y) (* (* x y) foo))', 'lambda stringification');
$return = $pl->eval("(eval '(bar 2 3) '((bar $f_str) (foo 7) (* (op *))))");
isa_ok($return, 'PerLisp::Expr::Number', 'function return value');
is($return->to_simple, 42, 'right function return value');

# arithmetic operators
$return = $pl->eval('(eval (quote
    (= 42 (* (* 2 3) (+ 3 (/ 8 (- 4 2)))))
) (quote((= (op =)) (* (op *)) (+ (op +)) (- (op -)) (/ (op /)))))');
isa_ok($return, 'PerLisp::Expr::Boolean', 'equalness result');
is($return->to_string, 'true', 'right arithmetic calculation');
$return = $pl->eval("(eval '(< 17 42) '((< (op <))))");
isa_ok($return, 'PerLisp::Expr::Boolean', 'less-than result');
is($return->to_string, 'true', 'right less-than result');
$return = $pl->eval("(eval '(> 17 42) '((> (op >))))");
isa_ok($return, 'PerLisp::Expr::Boolean', 'less-than result');
is($return->to_string, 'false', 'right less-than result');

# unary operators
my $car = $pl->eval("(eval (quote
    (car (quote (17 42)))
) '((car (op car)) (quote (op quote))))");
isa_ok($car, 'PerLisp::Expr::Number', 'car of a list');
is($car->to_simple, 17, 'right car of a list');
my $cadr = $pl->eval("(eval (quote
    (car (cdr (quote (17 42))))
) '((car (op car)) (cdr (op cdr)) (quote (op quote))))");
isa_ok($cadr, 'PerLisp::Expr::Number', 'cadr of a list');
is($cadr->to_simple, 42, 'right cadr of a list');
my $type = $pl->eval("(eval '(type 42) '((type (op type))))");
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of a Number');
is($type->to_string, 'Number', 'right type of a Number');
$type = $pl->eval("(eval (quote
    (type (quote foo))
) '((type (op type)) (quote (op quote))))");
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of a Symbol');
is($type->to_string, 'Symbol', 'right type of a Symbol');
$type = $pl->eval("(eval (quote
    (type foo)
) '((type (op type)) (foo (1 2 3))))");
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of a List');
is($type->to_string, 'List', 'right type of a List');
$type = $pl->eval("(eval (quote
    (type +)
) '((type (op type)) (+ (op +))))");
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of an Operator');
is($type->to_string, 'List', 'right type of an Operator (List!)');
$type = $pl->eval("(eval (quote
    (type (lambda (x) (* x x)))
) '((type (op type)) (lambda (op lambda))))");
isa_ok($type, 'PerLisp::Expr::Symbol', 'type of a Function');
is($type->to_string, 'List', 'right type of a Function (List!)');
$return = $pl->eval("(eval (quote
    (= (quote ()) nil)
) '((= (op =)) (quote (op quote)) (nil ())))");
isa_ok($return, 'PerLisp::Expr::Boolean', 'return value of =');
is($return->to_string, 'true', 'nil = empty list');

# initial-context
$return = $pl->eval("(eval (quote
    (cons (cond (= 42 17) 17 42) (cons (+ 3 4) nil))
) initial-context)");
isa_ok($return, 'PerLisp::Expr::List', 'return value with initial-context');
is_deeply($return->to_simple, [42, 7], 'right return value (initial-context)');

# functions
$return = $pl->eval("(eval '(nil? nil) initial-context)");
isa_ok($return, 'PerLisp::Expr::Boolean', 'return value of nil?');
is($return->to_string, 'true', 'nil? of empty list');
my $caar = $pl->eval("(eval '(caar (quote ((1 2) 3))) initial-context)");
isa_ok($caar, 'PerLisp::Expr::Number', 'caar');
is($caar->to_simple, 1, 'right caar');
$cadr = $pl->eval("(eval '(cadr (quote ((1 2) 3))) initial-context)");
isa_ok($cadr, 'PerLisp::Expr::Number', 'cadr');
is($cadr->to_simple, 3, 'right cadr');
my $cddr = $pl->eval("(eval '(cddr (quote (1 2 3))) initial-context)");
isa_ok($cddr, 'PerLisp::Expr::List', 'cddr');
is_deeply($cddr->to_simple, [3], 'right cddr');
my $caddr = $pl->eval("(eval '(caddr (quote (1 2 3))) initial-context)");
isa_ok($caddr, 'PerLisp::Expr::Number', 'caddr');
is($caddr->to_simple, 3, 'right caddr');
my $cadar = $pl->eval("(eval '(cadar (quote ((1 2) 3))) initial-context)");
isa_ok($cadar, 'PerLisp::Expr::Number', 'cadar');
is($cadar->to_simple, 2, 'right cadar');

__END__
