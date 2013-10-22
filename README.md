PerLisp
=======

This is a simple statically scoped Lisp interpreter, written in Perl. During
the lecture "Structure and Interpretation of Programming Languages", held by
Achim Clausing (WWU Münster, Germany), I needed to try out different things,
so I wrote this.

**DISCLAIMER** This is **not** production ready. I use it to play around and
I think there are many bugs lurking around. You have been warned! :-)

How to start?
-------------

Install the distro like a normal Perl distro:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install
    $ make clean

Now you can call the perlisp script which starts a read eval print loop:

    $ perlisp

View the API docs via

    $ perldoc PerLisp

If you don't want to install all that stuff, you can call the perlisp script
from the project root directory:

    $ cd ~/code/perlisp
    $ perl perlisp

And it should just work. Now let's go!

PerLisp uses the bind operator to bind values to names, you have a lambda
operator to generate functions and the convenience operator define to bind a
function to a name in one step. With the bound operator you get a list of all
bound names. Most of them come from the init.perlisp file which is loaded while
the interpreter starts.

Start typing something like this:

    (+ 17 25)
    ->  42
    (define (square x) (* x x))
    ->  Function: (x) -> (* x x)
    (square 42)
    ->  1764

You can find more inspirations from PerLisp::Init and the tests, especially
t/50-init.t, which shows some use cases for the init functions.

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
* PerLisp::Init - a container package around the init script

View the code for more implementation details, I tried hard to make it very
readable (even if you don't know much Perl).

Author, bug reports, license
----------------------------

Copyright (c) 2010-2013 Mirko Westermeier, <mirko@westermeier.de>

This software is released under the MIT license (view MIT-LICENSE for details).
If you found a bug, please contact me via mail or github. You can also use
github's issue tracker. Please provide (failing) tests for your bugs, patches
or feature requests.
