package Encode::Bijou64;

use strict;
use warnings;
use Exporter qw(import);
use Carp qw(croak);

our @EXPORT = qw(encode_bijou64 decode_bijou64);

# https://blogs.perl.org/users/grinnz/2018/04/a-guide-to-versions-in-perl.html
our $VERSION = 'v0.2.1';

################################################################################
################################################################################

# tag, num_bytes, max
my @TIERS = (
	[0xF8, 1,                    248],
	[0xF9, 2,                    504],
	[0xFA, 3,                 66_040],
	[0xFB, 4,             16_843_256],
	[0xFC, 5,          4_311_810_552],
	[0xFD, 6,      1_103_823_438_328],
	[0xFE, 7,    282_578_800_148_984],
	[0xFF, 8, 72_340_172_838_076_920],
);

my %DECODE;
for my $tier (@TIERS) {
    my ($tag, $bytes, $base) = @$tier;

    $DECODE{$tag} = [$bytes, $base];
}

################################################################################

sub encode_bijou64 {
	my ($n) = @_;

	if (!defined($n)) {
		croak("encode_bijou64(): undefined value");
	}

	if ($n !~ /^\d+\z/) {
		croak("encode_bijou64(): positive integer required");
	}

	return pack("C", $n)
	if $n <= 0xF7;

	for my $tier (@TIERS) {
		my ($tag, $bytes, $base) = @$tier;

		my $max = 0;
		if ($bytes < 8) {
			# One less than the starting point of the NEXT tier
			$max = $base + (1 << ($bytes * 8)) - 1;
		} else {
			$max = 18446744073709551615; # 2^64-1
		}

		if ($n <= $max) {
			my $v   = $n - $base;
			my $out = pack("C", $tag);

			for (reverse 0 .. $bytes - 1) {
				$out .= pack("C", ($v >> ($_ * 8)) & 0xFF);
			}

			return $out;
		}
	}

	croak("encode_bijou64(): integer $n too large");
}

sub decode_bijou64 {
	my ($buf) = @_;

	if (!defined($buf)) {
		croak("decode_bijou64(): undefined value");
	}

	if (!length($buf)) {
		croak("decode_bijou64(): empty buffer");
	}

	my $tag        = ord(substr($buf, 0, 1));
	my $output_len = length($buf);

	# Short/simple decode
	if ($tag <= 0xF7) {
		if ($output_len > 1) {
			croak("decode_bijou64(): buffer too long");
		}

		return $tag;
	}

	my $tier = $DECODE{$tag};

	if (!$tier) {
		my $msg = sprintf("decode_bijou64(): invalid tag 0x%02X", $tag);
		croak($msg);
	}

	my ($bytes, $base) = @$tier;
	my $target_size    = $bytes + 1;

	# Make sure our output matches the size we're expecting
	if ($output_len != $target_size) {

		# We should only make it here if the input data is invalid
		if ($output_len < $target_size) {
			croak("decode_bijou64(): buffer too short");
		} elsif ($output_len > $target_size) {
			croak("decode_bijou64(): buffer too long");
		}
	}

	my $v = 0;
	for my $i (0 .. $bytes - 1) {
		$v = ($v << 8) | ord(substr($buf, 1 + $i, 1));
	}

	my $ret = $base + $v;

	return $ret;
}

1;

################################################################################
################################################################################

=encoding utf8

=head1 NAME

Encode::Bijou64 - Encode and decode Bijou64 integers

=head1 SYNOPSIS

  use Encode::Bijou64;

  my $bytes = encode_bijou64(123456); # 0xfa00e048
  my $num   = decode_bijou64($bytes); # 123456

=head1 DESCRIPTION

Encode::Bijou64 implements the Bijou64 variable-length
integer encoding format described by Ink & Switch.

Small integers occupy fewer bytes while preserving
efficient decoding.

=head2 BYTES NEEDED

Encoding integers will result in a string of this many bytes

  Integer Range                   Total Size
  ------------------------------------------
  < 247                           1 byte
  < 503                           2 bytes
  < 66,039                        3 bytes
  < 16,843,255                    4 bytes
  < 4,311,810,551                 5 bytes
  < 1,103,823,438,327             6 bytes
  < 282,578,800,148,983           7 bytes
  < 72,340,172,838,076,919        8 bytes
  < 18,446,744,073,709,551,615    9 bytes

=head1 FUNCTIONS

=head2 encode_bijou64($integer)

Encodes a non-negative integer into a Bijou64 byte string.

=head2 decode_bijou64($bytes)

Decodes a Bijou64 byte string and returns the integer value.

=head1 SEE ALSO

https://www.inkandswitch.com/tangents/bijou64/

=head1 AUTHOR

Scott Baker

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

=cut

# vim: tabstop=4 shiftwidth=4 noexpandtab autoindent softtabstop=4
