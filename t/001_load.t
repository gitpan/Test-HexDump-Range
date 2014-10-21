
use strict ;
use warnings ;

use Test::NoWarnings ;

use Test::More qw(no_plan);
use Test::Exception ;
#use Test::UniqueTestNames ;

BEGIN { use_ok( 'Test::HexDump::Range' ) or BAIL_OUT("Can't load module"); } ;

my $object = new Test::HexDump::Range ;

is(defined $object, 1, 'default constructor') ;
isa_ok($object, 'Test::HexDump::Range');

my $new_config = $object->new() ;
is(defined $new_config, 1, 'constructed from object') ;
isa_ok($new_config , 'Test::HexDump::Range');

dies_ok
	{
	Test::HexDump::Range::new () ;
	} "invalid constructor" ;
