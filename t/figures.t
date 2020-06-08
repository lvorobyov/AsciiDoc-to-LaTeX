#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use_ok('AsciiDoc');

my $ad = <<AD;
image::fig/blackness.png[Black square of Malevich]
AD

my $tex = <<TEX;
\\begin{figure}[H]
\\centering
\\includegraphics{fig/blackness}
\\caption{Black square of Malevich}
\\label{fig:blackness}
\\end{figure}
TEX

ok (process_ad($ad) eq $tex, 'simple figure');

$ad = <<AD;
[width="70%"]
image::fig/blackness.png[Black square of Malevich]
AD

$tex = <<TEX;
\\begin{figure}[H]
\\centering
\\includegraphics[width=.7\\linewidth]{fig/blackness}
\\caption{Black square of Malevich}
\\label{fig:blackness}
\\end{figure}
TEX

ok (process_ad($ad) eq $tex, 'scaled figure');

$ad = <<AD;
[width="50%"]
image::fig/blackness.png[Black square of Malevich,float=right]
AD

$tex = <<TEX;
\\begin{wrapfigure}{r}{.5\\linewidth}
\\centering
\\includegraphics[width=.5\\linewidth]{fig/blackness}
\\caption{Black square of Malevich}
\\label{fig:blackness}
\\end{wrapfigure}
TEX

ok (process_ad($ad) eq $tex, 'wrapped figure');

$ad = <<AD;
image::fig/drawing.tex[The simple vector graphics]
AD

$tex = <<TEX;
\\begin{figure}[H]
\\centering
\\input{fig/drawing}
\\caption{The simple vector graphics}
\\label{fig:drawing}
\\end{figure}
TEX

ok (process_ad($ad) eq $tex, 'tikz picture');

done_testing();

