#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'PerLisp' );
}

diag( "Testing PerLisp $PerLisp::VERSION, Perl $], $^X" );
