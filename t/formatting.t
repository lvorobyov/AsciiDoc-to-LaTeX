#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use_ok('AsciiDoc');

my $ad = q(
The _coolest_ assignment in Perl5 *world* is typesetting beautiful documents as write an [underline]#essay# in prose or poem.
);

my $tex = q(
The \textit{coolest} assignment in Perl5 \textbf{world} is typesetting beautiful documents as write an \underline{essay} in prose or poem.
);

ok(process_ad($ad) eq $tex, 'formatting');

$ad = q(
The SQL query `SELECT * FROM dictionary` retrives all data from table `dictionary`.
);

$tex = q(
The SQL query \texttt{SELECT * FROM dictionary} retrives all data from table \verb|dictionary|.
);

ok(process_ad($ad) eq $tex, 'inline code');

done_testing();

