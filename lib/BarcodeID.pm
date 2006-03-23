package BarcodeID;

=head1 NAME

BarcodeID - Perform simple identification and validation on UPC-A, UPC-E, EAN-8, EAN-13, CODE39 barcodes

=head1 SYNOPSIS

  use BarcodeID qw/validate identify barcode type/;

  my $id = BarcodeID->new('barcode' => '012345');
  print $id->barcode();
  $id->identify();
  print $id->type();
  if($id->validate())
  {
    print "Invalid barcode";
  }

  #### OR

  my $id = BarcodeID->new('barcode' => '012345', 'type' => 'UPCE');

  if($id->validate())
  {
    print "Invalid barcode";
  }

=head1 DESCRIPTION

When passing the barcode you should omit the check digit, so for a UPCA you should
only be passing 11 digits, for a UPCE you should just be passing 6, EAN-8 should be 7
EAN-13 should be 12, the only difference in CODE39 which is variable length and as 
such the only checking performed here is that is doesn't contain invalid characters.

You can just pass in a barcode and identify it or you can pass in a barcode and a type and 
validate it.

=cut

use base 'Exporter';
use strict;
use warnings;
use AutoLoader qw(AUTOLOAD);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our @ISA = qw(Exporter);


@EXPORT_OK = qw/new validate identify barcode type/;
@EXPORT      = qw//;
%EXPORT_TAGS = (all => [@EXPORT_OK]);
$VERSION     = "0.1";

=head1 FUNCTIONS

=head2 new

my $id = BarcodeID->new('barcode' => 'A12345');

You can pass in the optional parameters 'barcode' and 'type'

=cut

sub new {
	my $type = shift;
	my %params = @_;
	my $self = {};
	$self->{'barcode'} = $params{'barcode'};
	$self->{'type'}    = $params{'type'};
	bless $self, $type;
	return $self;
}

=head2 validate

my $a = $id->validate();

This will check and see if the type has been set if not it 
will identify the type and then validate, if the type is set it 
will just validate.

This returns 0 for pass and 1 for fail.

=cut

sub validate {
	my $self = shift;
    if( $self->{'type'} )
	{
       return _validate_identified($self);
	}
	else
	{
       return _identify_validate($self);
	}
}

=head2 new

my $type = $id->identify();

The identify function just checks the length of the barcode, 
additionally if checks to see if it contains none numeric characters, 
if it does it automatically identifys it as CODE39, please note it is 
not validated 'A##$@%' would be identified as a CODE39 but it is invalid 
when the validate function is call it would fail this.

This function will return the name of the type, or a 2 on the event of 
failure to identify.

=cut

sub identify {
	my $self = shift;

    if((length($self->{'barcode'}) > 12) || ($self->{'barcode'} !~ /^\d*$/))
	{
		$self->{'type'} = 'CODE39';
   		return $self->{'type'};
	}
	elsif(length($self->{'barcode'}) == 11)
	{
		$self->{'type'} = 'UPCA';
   		return $self->{'type'};
	}
	elsif(length($self->{'barcode'}) == 6)
	{
		$self->{'type'} = 'UPCE';
   		return $self->{'type'};
	}
	elsif(length($self->{'barcode'}) == 7)
	{
		$self->{'type'} = 'EAN8';
   		return $self->{'type'};
	}
	elsif(length($self->{'barcode'}) == 12)
	{
		$self->{'type'} = 'EAN13';
   		return $self->{'type'};
	}
	else
	{
		return 2;
	}
}

=head2 barcode

my $barcode = $id->barcode();
# or
$id->barcode('1029384');

This function will allow you to view or set the barcode 
parameter, if you pass a parameter it will set the barcode to 
that parameter, if you do not it will just return the 
currently set barcode.

=cut

sub barcode {
	my ($self, $newval) = @_;
    $self->{'barcode'} = $newval if $newval;
	return $self->{'barcode'};
}

=head2 type

my $type = $id->type();
# or
$id->type('EAN8');

This function will allow you to view or set the barcode type
parameter, if you pass a parameter it will set the type to 
that parameter, if you do not it will just return the 
currently set barcode type.

=cut

sub type {
	my ($self, $newval) = @_;
	$self->{'type'} = $newval if $newval;
	return $self->{'type'};
}

####
# _validate_identified
# Internal sub to validate a barcode by length and 
# a regex of valid characters.
#

sub _validate_identified {
	my $self = shift;

	my %barcode_chars = (
		                 'UPCA'   => ['0123465789','11'],
			             'UPCE'   => ['0123456789','6'],
				         'EAN8'   => ['0123456789','7'],
					     'EAN13'  => ['0132456789','12'],
						 'CODE39' => ['0-9A-Z\-.*\$/+%','0'],
	);

	if ( ( length($self->{'barcode'}) == $barcode_chars{$self->{'type'}}[1] ) ||
		   ($barcode_chars{$self->{'type'}}[1] == 0) )
	{
		my $regexp = $barcode_chars{$self->{'type'}}[0];
		if( $self->{'barcode'} !~ /^[$regexp]*$/ )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{

		return 1;
	}
}

####
# _identify_validate
# Internal sub to identify a barcode by length and 
# a regex of valid characters.  It will then validate and 
# return the result.
#

sub _identify_validate {
	my ($self) = shift;

    if((length($self->{'barcode'}) > 13) || ($self->{'barcode'} !~ /^\d*$/))
	{
		$self->{'type'} = 'CODE39';
		return $self->_validate_identified($self);
	}
	elsif(length($self->{'barcode'}) == 11)
	{
		$self->{'type'} = 'UPCA';
		return $self->_validate_identified($self);
	}
	elsif(length($self->{'barcode'}) == 6)
	{
		$self->{'type'} = 'UPCE';
		return $self->_validate_identified($self);
	}
	elsif(length($self->{'barcode'}) == 7)
	{
		$self->{'type'} = 'EAN8';
		return $self->_validate_identified($self);
	}
	elsif(length($self->{'barcode'}) == 12)
	{
		$self->{'type'} = 'EAN13';
		return $self->_validate_identified($self);
	}
	else
	{
		return 1;
	}    
}


1;
__END__
=head1 BUGS

None known please email if you find any!

=head1 TODO

Add a method to determine and return the check character.

=head1 BUGS and QUERIES

Please direct all correspondence regarding this module to:
  bmaynard@cpan.org

=head1 AUTHOR

Ben Maynard, E<lt>cpan@geekserv.comE<gt> E<lt>http://www.webcentric-hosting.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Ben Maynard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut