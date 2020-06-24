#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use_ok('AsciiDoc');

my $ad = <<AD;
Suppose, that latexmath:[A \\subset B]. There is latexmath:[C \\supset B]. Thus, latexmath:[A \\subset C].
AD

my $tex = <<TEX;
Suppose, that \$A \\subset B\$. There is \$C \\supset B\$. Thus, \$A \\subset C\$.
TEX

ok(process_ad($ad) eq $tex, 'inline math');

$ad = q(
latexmath::[a * (b + c) = a * b + a * c] [[eq:distributive]]
);

$tex = q(
\begin{equation}\label{eq:distributive}
a \times (b + c) = a \times b + a \times c
\end{equation}
);

ok(process_ad($ad) eq $tex, 'display math with label');

ok(to_latex('latexmath::[a * b = b * a]') eq '$$ a \times b = b \times a $$', 'display math');

$ad = <<AD;
The _easiest_ way to type *math* equation is latexmath:[a_i + b_i * c_i \\forall i \\in R].
AD

$tex = <<TEX;
The \\textit{easiest} way to type \\textbf{math} equation is \$a_i + b_i \\times c_i \\forall i \\in R\$.
TEX

ok (process_ad($ad) eq $tex, 'mixed math');

done_testing();

