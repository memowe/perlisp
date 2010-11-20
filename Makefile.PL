use strict;
use warnings;
use ExtUtils::MakeMaker;

use 5.10.0;

WriteMakefile(
    NAME                => 'PerLisp',
    AUTHOR              => 'Mirko Westermeier <mirko@westermeier.de>',
    VERSION_FROM        => 'lib/PerLisp.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'mit')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'    => 0,
        'IO::Handle'    => 0,
        'File::Slurp'   => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PerLisp-*' },
);
