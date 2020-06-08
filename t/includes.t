#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

use_ok('AsciiDoc');

my $ad = <<AD;
This is my humble opinion
include::attachments.ad[]
And so on!
AD

my $tex = <<TEX;
This is my humble opinion
\\input{attachments}
And so on!
TEX

ok(process_ad($ad) eq $tex, 'includes');

done_testing();

