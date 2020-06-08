#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use_ok('AsciiDoc');

my $ad = <<AD;
.Title
|===
| a | b | c
| d | e | f
|===
AD

my $tex = <<TEX;
\\begin{table}[H]
\\caption{Title}
\\centering
\\begin{tabu} to 1\\linewidth {|X|X|X|} \\hline
 a & b & c \\\\ \\hline
 d & e & f \\\\ \\hline
\\end{tabu}
\\end{table}
TEX

ok (process_ad($ad) eq $tex, 'the simple table');

$ad = <<AD;
.The long table
[long]
|===
| a | b | c

| d | e | f
| g | h | i
|===
AD

$tex = <<TEX;
\\begin{longtabu} to 1\\linewidth {|X|X|X|} \
\\caption{The long table} \\\\ \\hline
 a & b & c \\\\ \\hline
\\endfirsthead
\\multicolumn{3}{r}{\\thetablecontinue} \\\\ \\hline
 a & b & c \\\\ \\hline
\\endhead
\\hline
\\endfoot
 d & e & f \\\\ \\hline
 g & h & i \\\\ \\hline
\\end{longtabu}
TEX

ok(process_ad($ad) eq $tex, 'the long table');

$ad = <<AD;
.Title
[cols="<2,2*^3,>2,^"]
|===
| a | b | c | d | e
|===

AD

$tex = <<TEX;
\\begin{table}[H]
\\caption{Title}
\\centering
\\begin{tabu} to 1\\linewidth {|X[2,l]|X[3,c]|X[3,c]|X[2,r]|c|} \\hline
 a & b & c & d & e \\\\ \\hline
\\end{tabu}
\\end{table}

TEX

ok(process_ad($ad) eq $tex, 'specify columns');

$ad = <<AD;
[width="70%"]
|===
.2+| a .3+| b 2+| c 2+| d .2+| e
                | f  2.2+| g | h
   | i          | j      | k | l
|===
AD

$tex = <<TEX;
\\begin{table}[H]
\\centering
\\begin{tabu} to .7\\linewidth {|X|X|X|X|X|X|X|} \\hline
 \\multirow{2}{*}{a} & \\multirow{3}{*}{b} & \\multicolumn{2}{c|}{c} & \\multicolumn{2}{c|}{d} & \\multirow{2}{*}{e} \\\\ \\cline{3-6}
 & & f & \\multicolumn{2}{c|}{\\multirow{2}{*}{g}} & h & \\\\ \\cline{1-1}\\cline{3-3}\\cline{6-7}
 i & & j & & & k & l \\\\ \\hline
\\end{tabu}
\\end{table}
TEX

ok(process_ad($ad) eq $tex, 'spanned cells');

done_testing();

