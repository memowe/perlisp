package PerLisp::Init;

use strict;
use warnings;

our $definitions = join '' => <DATA>;

1;
__DATA__
; "the" true
(bind true (= 1 1))

; "tre" false
(bind false (not true))

; (not) equal aliases
(bind eq =)

(define (neq x y) (not (eq x y)))

(bind != neq)

; empty list helper
(define (nil? l) (= l '()))

; type helpers
(define (number?   x) (= (type x) 'Number))
(define (string?   x) (= (type x) 'String))
(define (symbol?   x) (= (type x) 'Symbol))
(define (boolean?  x) (= (type x) 'Boolean))
(define (list?     x) (= (type x) 'List))
(define (quote?    x) (= (type x) 'QuoteExpr))
(define (function? x) (= (type x) 'Function))
(define (operator? x) (= (type x) 'Operator))

; car/cdr convenience functions
(define (caar l)    (car (car l)))
(define (cadr l)    (car (cdr l)))
(define (cdar l)    (cdr (car l)))
(define (cddr l)    (cdr (cdr l)))

(define (caaar l)   (car (caar l)))
(define (caadr l)   (car (cadr l)))
(define (cadar l)   (car (cdar l)))
(define (caddr l)   (car (cddr l)))
(define (cdaar l)   (cdr (caar l)))
(define (cdadr l)   (cdr (cadr l)))
(define (cddar l)   (cdr (cdar l)))
(define (cdddr l)   (cdr (cddr l)))

(define (caaaar l)  (car (caaar l)))
(define (caaadr l)  (car (caadr l)))
(define (caadar l)  (car (cadar l)))
(define (caaddr l)  (car (caddr l)))
(define (cadaar l)  (car (cdaar l)))
(define (cadadr l)  (car (cdadr l)))
(define (caddar l)  (car (cddar l)))
(define (cadddr l)  (car (cdddr l)))
(define (cdaaar l)  (cdr (caaar l)))
(define (cdaadr l)  (cdr (caadr l)))
(define (cdadar l)  (cdr (cadar l)))
(define (cdaddr l)  (cdr (caddr l)))
(define (cddaar l)  (cdr (cdaar l)))
(define (cddadr l)  (cdr (cdadr l)))
(define (cdddar l)  (cdr (cddar l)))
(define (cddddr l)  (cdr (cdddr l)))

; map (apply a function on all list elements)
(define (map f l)
    (cond (nil? l) '()
        (cons (f (car l)) (map f (cdr l)))))

; filter (return all elements of a list which are true under a function)
(define (filter f l)
    (cond
        (nil? l) '()
        (not (f (car l))) (filter f (cdr l))
        (cons (car l) (filter f (cdr l)))))

; reduce (reduce a list with a dyadic function and a neutral element)
(define (reduce f l neutral)
    (cond (nil? l) neutral
        (f (car l) (reduce f (cdr l) neutral))))
