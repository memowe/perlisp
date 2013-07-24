use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PerLisp',
    VERSION_FROM        => 'lib/PerLisp.pm',
    ABSTRACT            => 'A simple Lisp interpreter, written in Perl',
    AUTHOR              => 'Mirko Westermeier <mirko@westermeier.de>',
    LICENSE             => 'mit',
    META_MERGE          => {
        resources   => {
            repository  => 'https://github.com/memowe/perlisp',
            bugtracker  => 'https://github.com/memowe/perlisp/issues',
        },
    },
    MIN_PERL_VERSION    => '5.10.1',
    PREREQ_PM => {

        # core modules
        'Test::More'    => '0.92',
        'IO::Handle'    => '1.28',

        # non core modules
        #'Mo'            => '0.35', # inlined!
    },
    EXE_FILES => ['perlisp'],
);
