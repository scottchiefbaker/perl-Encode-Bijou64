## Name

Encode::Bijou64 - Encode and decode Bijou64 integers

## Synopsis

```perl
use Encode::Bijou64;

my $bytes = encode_bijou64(123456); # 0xfa00e048
my $num   = decode_bijou64($bytes); # 123456
```

## Description

Encode::Bijou64 implements the Bijou64 variable-length
integer encoding format described by Ink & Switch.

Small integers occupy fewer bytes while preserving
efficient decoding.

### Bytes Needed

Encoding integers will result in a string of this many bytes

```
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
```

## Functions

### encode\_bijou64($integer)

Encodes a non-negative integer into a Bijou64 byte string.

### decode\_bijou64($bytes)

Decodes a Bijou64 byte string and returns the integer value.

## See Also

https://www.inkandswitch.com/tangents/bijou64/

## Author

Scott Baker

## License

Same terms as Perl itself.
