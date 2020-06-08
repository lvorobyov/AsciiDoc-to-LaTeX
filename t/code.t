#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;

use_ok( 'AsciiDoc' );

my $ad = <<AD;
```
abcd
```
AD

my $tex = <<TEX;
\\begin{verbatim}
abcd
\\end{verbatim}
TEX

ok(process_ad($ad) eq $tex, 'verbatim');

$ad = <<AD;
```ruby
puts (1..3).reduce(:+)
```
AD

$tex = <<TEX;
\\begin{minted}{ruby}
puts (1..3).reduce(:+)
\\end{minted}
TEX

ok(process_ad($ad) eq $tex, 'minted');

ok(to_latex('`code`') eq '\verb|code|', 'inline');

$ad = <<AD;
code::src/main.cpp
code::src/header.h
code::src/main.cpp:10
AD

$tex = <<TEX;
\\inputminted{cpp}{src/main.cpp}
\\inputminted{cpp}{src/header.h}
\\inputminted[firstline=10]{cpp}{src/main.cpp}
TEX

ok(process_ad($ad) eq $tex, 'minted from file');

$ad = <<AD;
[columns=2,numbers=none]
code::results.txt
AD

$tex = <<TEX;
\\begin{multicols}{2}
\\inputminted[numbers=none]{text}{results.txt}
\\end{multicols}
TEX

ok(process_ad($ad) eq $tex, 'multicolumn minted');

done_testing();

