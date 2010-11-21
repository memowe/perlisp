PerLisp
=======

This is a simple statically scoped Lisp interpreter, written in Perl. During
the lecture "Structure and Interpretation of Programming Languages", held by
Achim Clausing (WWU Münster, Germany), I needed to try out diffent things, so I
wrote this.

How to start?
-------------

Chdir to the project directory (which is where you found this README, I think)
and execute the read eval print loop tool (you need Perl 5.10 to do this):

    $ cd ~/code/perlisp
    $ perl perlisp

PerLisp uses the bind operator to bind values to names, you have a lambda
operator to generate functions and the convenience operator define to bind a
function to a name in one step. With the bound operator you get a list of all
bound names. Most of them come from the init.perlisp file which is loaded while
the interpreter starts.

Now start typing something like this:

    (+ 17 25)
    ->  42
    (define (square x) (* x x))
    ->  Function: (x) -> (* x x)
    (square 42)
    ->  1764

You can find more inspirations from init.perlisp and the tests, especially
t/50-init-file.t, which shows some use cases for the init functions.

This distribution is a installable perl module, so you can

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install
    $ make clean

but you don't have to. While I think the code is pretty readable, it might be
a good thing to install the distro and

    $ perldoc PerLisp

to view the API.

Interpreter details
-------------------

The implementation is straight forward. PerLisp uses objects from the following
classes to get you started with Lisp:

* PerLisp::Base - base class for all PerLisp classes (simplified Mojo::Base)
* PerLisp::Lexer - generates a PerLisp::TokenStream from Lisp strings
* PerLisp::Parser - generates PerLixp::Expr::* objects from TokenStream
* PerLisp::Expr::* - Lisp expressions
* PerLisp::Context - objects which store value-name bindings
* PerLisp::Operators - perl implementations of built-in operators

View the code for more implementation details, I tried hard to make it very
readable (even if you don't know much Perl).

Author, bug reports, license
----------------------------

Copyright (c) 2010 Mirko Westermeier, <mirko@westermeier.de>

This software is released under the MIT license (view MIT-LICENSE for details).
If you found a bug, please contact me via mail or github. You can also use
github's issue tracker. Please provide (failing) tests for your bugs, patches
or feature requests.
