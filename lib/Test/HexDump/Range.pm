
package Test::HexDump::Range ;

use strict;
use warnings ;
use Carp qw(carp croak confess) ;

BEGIN 
{
use Sub::Exporter -setup => 
	{
	exports => [ qw(diff_range) ],
	groups  => 
		{
		all  => [ qw() ],
		}
	};
	
use vars qw ($VERSION);
$VERSION     = '0.01_1';
}

#-------------------------------------------------------------------------------

#~ use English qw( -no_match_vars ) ;

use Readonly ;
#~ Readonly my $EMPTY_STRING => q{} ;

use Data::HexDump::Range ;

#-------------------------------------------------------------------------------

=head1 NAME

Test::HexDump::Range - Compare binary data and displays a diff of two range dumps if they differ

=head1 SYNOPSIS

 use Test::HexDump::Range  qw(diff_range) ;
 
 my $range_description = 'magic cookie,5, bright_cyan:type,12:  bf, x5b5    :meta_data,15:  size,2: offset,7' ;
 
 my $expected_binary = '01234' . '567890123456' . '789012345678901' . '23' . '4567890' ;
 my $got_binary =      '01234' . '5XY890123456' . '789012345678901' . 'Z3' . '4567890' ;
 
 print diff_range($range_description, $expected_binary, $got_binary) ; # use default configuration
 
 # below is not implemented yet !
 
 my $dr = Test::HexDump::Range->new
			(
			DISPLAY_COLUMN_NAMES => 1,
			DISPLAY_RULER => 1,
			INTER_LINE => 0,
			COLORS => ['bright_green', 'bright_yellow','bright_cyan', 'bright_red', 'bright_white'],
			...
			) ;
			
 print $dr->diff($range_description, $expected_binary, $got_binary) ;
 
 is_range_ok($range; $expected_binary, $got_binary) ;

=head1 DESCRIPTION

Takes a range description and two data chunks and displayes a binary diff highlighted according to the range description. The 
dump is always in horizontal orientation.

=head1 DOCUMENTATION

This is a developer relase. the only thing working is the L<diff_range> subroutine (which may be the only thing that you need) and only
in the static configuration this module was built with, ANSI format, ...

Example of output:

=begin html

<pre style ="font-family: monospace; background-color: #000 ;">
<span style = 'color:#fff; '>00000000</span><span style = 'color:#fff; '></span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#0f0; '>30 31 32 33 34 </span><span style = 'color:#fff;  color:#ff0; '>35 36 37 38 39 30 31 32 33 34 35 </span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#0f0; '>5:magic cookie</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff;  color:#ff0; '>12:type</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
         <span style = 'color:#fff;  color:#0f0; '>30 31 32 33 34 </span><span style = 'color:#fff;  color:#ff0; '>35 </span><span style = 'color:#fff;  color:#fff;  background-color:#a00; '>58 59 </span><span style = 'color:#fff;  color:#ff0; '>38 39 30 31 32 33 34 35 </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
	 
</span><span style = 'color:#fff; '>00000010</span><span style = 'color:#fff; '></span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#ff0; '>36 </span><span style = 'color:#fff;  color:#f00; '>37 38 39 30 31 32 33 34 35 36 37 38 39 30 31 </span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#ff0; '>12:type</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff;  color:#f00; '>15:meta_data</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
         </span><span style = 'color:#fff;  color:#ff0; '>36 </span><span style = 'color:#fff;  color:#f00; '>37 38 39 30 31 32 33 34 35 36 37 38 39 30 31 </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
	 
</span>
<span style = 'color:#fff; '>00000020</span><span style = 'color:#fff; '></span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#fff; '>32 33 </span><span style = 'color:#fff;  color:#0f0; '>34 35 36 37 38 39 30                      </span><span style = 'color:#fff; '> </span><span style = 'color:#fff;  color:#fff; '>2:size</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff;  color:#0f0; '>7:offset</span><span style = 'color:#fff; '>, </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
         </span><span style = 'color:#fff;  color:#fff;  background-color:#a00; '>5a </span><span style = 'color:#fff;  color:#fff; '>33 </span><span style = 'color:#fff;  color:#0f0; '>34 35 36 37 38 39 30                      </span><span style = 'color:#fff; '> </span><span style = 'color:#fff; '>
</span></span></pre>

=end html

=head1 SUBROUTINES/METHODS

=cut

#-------------------------------------------------------------------------------

Readonly my $NEW_ARGUMENTS => 	
	[
	qw(
	COLORS
	INTER_LINE
	DISPLAY_COLUMN_NAMES
	DISPLAY_RULER
	
	NAME INTERACTION VERBOSE
	
	FORMAT
	DUMP_RANGE_DESCRIPTION
	COLOR 
	START_COLOR
	OFFSET_FORMAT 
	OFFSET_START
	DATA_WIDTH 
	DISPLAY_OFFSET 
	DISPLAY_ZERO_SIZE_RANGE_WARNING
	DISPLAY_ZERO_SIZE_RANGE 
	DISPLAY_RANGE_NAME
	MAXIMUM_RANGE_NAME_SIZE
	DISPLAY_RANGE_SIZE
	DISPLAY_ASCII_DUMP
	DISPLAY_HEX_DUMP
	DISPLAY_DEC_DUMP
	DISPLAY_BITFIELDS
	DISPLAY_BITFIELD_SOURCE
	BIT_ZERO_ON_LEFT
	COLOR_NAMES 
	)] ;

sub new
{
my ($invocant, @setup_data) = @_ ;

my $class = ref($invocant) || $invocant ;
confess 'Error: Invalid constructor call.' unless defined $class ;

my $object = {} ;

my ($package, $file_name, $line) = caller() ;
bless $object, $class ;

$object->Setup($package, $file_name, $line, @setup_data) ;

return($object) ;
}

#-------------------------------------------------------------------------------

sub Setup
{

=head2 [P] Setup()

Helper sub called by new.

=cut

my ($self, $package, $file_name, $line, @setup_data) = @_ ;

if (@setup_data % 2)
	{
	croak "Invalid number of argument '$file_name, $line'!" ;
	}

$self->{INTERACTION}{INFO} ||= sub {print @_} ;
$self->{INTERACTION}{WARN} ||= \&Carp::carp ;
$self->{INTERACTION}{DIE}  ||= \&Carp::croak ;
$self->{NAME} = 'Anonymous';
$self->{FILE} = $file_name ;
$self->{LINE} = $line ;

$self->CheckOptionNames($NEW_ARGUMENTS, @setup_data) ;

%{$self} = 
	(
	%{$self},
	INTER_LINE => 1,
	@setup_data,
	ORIENTATION => 'horizontal',
	) ;

$self->{INTERACTION}{INFO} ||= sub {print @_} ;
$self->{INTERACTION}{WARN} ||= \&Carp::carp ;
$self->{INTERACTION}{DIE}  ||= \&Carp::croak ;

my $location = "$self->{FILE}:$self->{LINE}" ;

if($self->{VERBOSE})
	{
	$self->{INTERACTION}{INFO}('Creating ' . ref($self) . " '$self->{NAME}' at $location.\n") ;
	}

return ;
}

#-------------------------------------------------------------------------------

sub CheckOptionNames
{

=head2 [P] CheckOptionNames()

Verifies the named options passed to the members of this class. Calls B<{INTERACTION}{DIE}> in case
of error. 

=cut

my ($self, $valid_options, @options) = @_ ;

if (@options % 2)
	{
	$self->{INTERACTION}{DIE}->('Invalid number of argument!') ;
	}

if('HASH' eq ref $valid_options)
	{
	# OK
	}
elsif('ARRAY' eq ref $valid_options)
	{
	$valid_options = { map{$_ => 1} @{$valid_options} } ;
	}
else
	{
	$self->{INTERACTION}{DIE}->("Invalid argument '$valid_options'!") ;
	}

my %options = @options ;

for my $option_name (keys %options)
	{
	unless(exists $valid_options->{$option_name})
		{
		$self->{INTERACTION}{DIE}->
				(
				"$self->{NAME}: Invalid Option '$option_name' at '$self->{FILE}:$self->{LINE}'\nValid options:\n\t"
				.  join("\n\t", sort keys %{$valid_options}) . "\n"
				);
		}
	}

if
	(
	   (defined $options{FILE} && ! defined $options{LINE})
	|| (!defined $options{FILE} && defined $options{LINE})
	)
	{
	$self->{INTERACTION}{DIE}->("$self->{NAME}: Incomplete option FILE::LINE!") ;
	}

return(1) ;
}

#-------------------------------------------------------------------------------

sub diff_range
{

=head2 diff_range($range_description, $expected_binary, $got_binary)

Compares two binary chunks and displays a hexadecimal dump witht a line from $expected_binary followed by a line
from $got_binary. The output is highlighted according to the range description. If a difference occures, the bytes are displayed
with a different backgound color.

I<Arguments>

=over 2 

=item * $range_description - A range description according to L<Data::HexDump::Range>

=item * $expected_binary - A String

=item * $got_binary - A String 

=back

I<Returns> - A String containing the diff

I<Exceptions> - Croaks on invalid input 

=cut

my ($range_description, $expected_binary, $got_binary) = @_ ;

my @colors = ('bright_green', 'bright_yellow','bright_cyan', 'bright_red', 'bright_white') ;
my $color_index = -1 ;

my @expected_ranges ;

#todo, use $self with local GATHER_CHUNK

my $hdr = Data::HexDump::Range->new
			(
			#~ FORMAT => 'HTML',
			DISPLAY_ASCII_DUMP => 0,
			DISPLAY_RANGE_NAME => 1,
			GATHERED_CHUNK => 
				sub 
				{
				my ($self, $chunk) = @_ ;
				
				$color_index++ ;
				$color_index = 0 if$color_index >= @colors ;

				$chunk->{COLOR} = $colors[$color_index] ;
				
				push @expected_ranges, $chunk ;
				
				return $chunk ;
				}
			) ;

my @dump1 = split /\n/, $hdr->dump($range_description, $expected_binary) ;

$color_index = -1 ;
my $hdr2 = Data::HexDump::Range->new
			(
			#~ FORMAT => 'HTML',
			DISPLAY_ASCII_DUMP => 0,
			DISPLAY_RANGE_NAME => 0,
			DISPLAY_OFFSET => 0,
			GATHERED_CHUNK => 
				sub 
				{
				my ($self, $chunk) = @_ ;
				
				my $expected_chunk = shift @expected_ranges ;
				
				$color_index++ ;
				$color_index = 0 if$color_index >= @colors ;
				
				if($expected_chunk->{DATA} ne $chunk->{DATA})
					{
					my @new_chunks ;
					my $new_chunk = '' ;
					
					my $same_byte_value ;
					my $previous_chunk_has_same_byte_value = 1 ;
					
					for my $byte_index  (0 .. length($expected_chunk->{DATA}) - 1)
						{
						my $got_byte  ;
						
						if(substr($expected_chunk->{DATA}, $byte_index, 1) eq ($got_byte = substr($chunk->{DATA}, $byte_index, 1)) )
							{
							$same_byte_value = 1 ;
							
							if($previous_chunk_has_same_byte_value == $same_byte_value) # same data again
								{
								$new_chunk .= $got_byte ;
								}
							}
						else
							{
							$same_byte_value = 0 ;
							
							if($previous_chunk_has_same_byte_value == $same_byte_value) #different data again
								{
								$new_chunk .= $got_byte ;
								}
							}
							
							
						if($previous_chunk_has_same_byte_value != $same_byte_value)
							{
							my $new_chunk_length = length($new_chunk) ;
							
							push @new_chunks,
									{
									NAME => $previous_chunk_has_same_byte_value ?  "$expected_chunk->{NAME}'<=$new_chunk_length>'" : "$expected_chunk->{NAME}'<!$new_chunk_length>'", 
									COLOR => $previous_chunk_has_same_byte_value ? $colors[$color_index] : 'bright_white on_red',
									OFFSET => $expected_chunk->{OFFSET},
									DATA =>  $new_chunk,
									IS_BITFIELD => $expected_chunk->{IS_BITFIELD},
									IS_SKIP => $expected_chunk->{IS_SKIP},
									IS_COMMENT => $expected_chunk->{IS_COMMENT},
									USER_INFORMATION => '',
									} if length($new_chunk) ;
									
							$previous_chunk_has_same_byte_value = $same_byte_value ;
							$new_chunk = $got_byte ;
							}
						}
						
					my $new_chunk_length = length($new_chunk) ;
					push @new_chunks,
							{
							NAME => $previous_chunk_has_same_byte_value ?  "$expected_chunk->{NAME}'<=$new_chunk_length>'" : "$expected_chunk->{NAME}'<!$new_chunk_length>'", 
							COLOR => $previous_chunk_has_same_byte_value ? $colors[$color_index] : 'bright_white on_red',
							OFFSET => $expected_chunk->{OFFSET},
							DATA =>  $new_chunk,
							IS_BITFIELD => $expected_chunk->{IS_BITFIELD},
							IS_SKIP => $expected_chunk->{IS_SKIP},
							IS_COMMENT => $expected_chunk->{IS_COMMENT},
							USER_INFORMATION => '',
							} ;
						
					return @new_chunks ;
					}
				else
					{
					$chunk->{COLOR} = $colors[$color_index] ;
					return $chunk;
					}
				}
			) ;
			
my @dump2 = split /\n/, $hdr2->dump($range_description, $got_binary) ;

my $ruler = Data::HexDump::Range->new( DISPLAY_RULER => 1) ;
my @ruler_x =  split /\n/, $ruler->dump('x,1', '1') ;

my $output = $ruler_x[0] . "\n" ;
$output .=  shift(@dump1) .  "\n" . ' ' x 9 . shift(@dump2) .  "\n\n"  while(@dump1) ;

return $output ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 BUGS AND LIMITATIONS

None so far.

=head1 AUTHOR

	Nadim ibn hamouda el Khemir
	CPAN ID: NKH
	mailto: nadim@cpan.org

=head1 COPYRIGHT AND LICENSE

Copyright Nadim Khemir 2010 .

This program is free software; you can redistribute it and/or
modify it under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

=item * the Artistic License version 2.0.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::HexDump::Range

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-HexDump-Range>

=item * RT: CPAN's request tracker

Please report any bugs or feature requests to  L <bug-test-hexdump-range@rt.cpan.org>.

We will be notified, and then you'll automatically be notified of progress on
your bug as we make changes.

=item * Search CPAN

L<http://search.cpan.org/dist/Test-HexDump-Range>

=back

=head1 SEE ALSO


=cut
