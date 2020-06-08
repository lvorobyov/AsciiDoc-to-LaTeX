#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use_ok('AsciiDoc');

ok(to_latex('= H1') eq '\chapter{H1}', 'chapter');
ok(to_latex('== H2') eq '\section{H2}', 'seciton');
ok(to_latex('=== H3') eq '\subsection{H3}', 'subsection');
ok(to_latex('==== H4') eq '\subsubsection{H4}', 'subsubsection');

done_testing();

