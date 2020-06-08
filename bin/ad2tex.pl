#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use 5.010;
use utf8;

use AsciiDoc;

while (<>) {
  chomp;
  s/\s+$//;
  print to_latex($_, qq(\n));
}
