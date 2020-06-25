#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use_ok('AsciiDoc');

my $ad = q(
[abstract]
The brief annotation.

);

my $tex = q(
\begin{abstract}
The brief annotation.
\end{abstract}

);

ok(process_ad($ad) eq $tex, 'one paragraph');

$ad = q(
[abstract]
--
The brief annotation.

Keywords: annotation.
--
);

$tex = q(
\begin{abstract}
The brief annotation.

Keywords: annotation.
\end{abstract}
);

ok(process_ad($ad) eq $tex, 'multiple paragraph');

done_testing();

