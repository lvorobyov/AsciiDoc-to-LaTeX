#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

use_ok( 'AsciiDoc' );

my $ad = <<AD;
My list:
. item1
.. item2
... item3

AD

my $expect = <<TEX;
My list:
\\begin{enumerate}
\\item item1
\\iitem item2
\\iiitem item3
\\end{enumerate}

TEX

ok(process_ad($ad) eq $expect, 'enumerate');

$ad = <<AD;
- item1
- item2
- item3

AD

$expect = <<TEX;
\\begin{itemize}
\\item item1
\\item item2
\\item item3
\\end{itemize}

TEX

ok(process_ad($ad) eq $expect, 'itemize');

$ad = <<AD;
5. item
6. item

AD

$expect = <<TEX;
\\begin{enumerate}[start=5]
\\item item
\\item item
\\end{enumerate}

TEX

ok(process_ad($ad) eq $expect, 'enum_with_start');

done_testing();

