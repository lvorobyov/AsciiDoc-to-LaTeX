#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use_ok('AsciiDoc');

my $ad = q(
= Appendix
[[app:animals]]

On the <<fig:cat,fig.>> you can see, that sizes of cats and dogs are correlated as explained in formula <<eq:relation>>
latexmath:[$$ 2 : 3 $$] [[eq:relation]]

Next, suppose that beginners in small science of animal say footnote:[Regardless rank or social status]
dogs definitely bigger then cats. Well, but there is a new surprised relation? that he don't know.

As explained in <<towards_animals>> more and more kings of gods are smallest that common cats.

More information in http://www.animals.com/dogs and http://www.drawbacks.com[Drawback]
);

my $tex = q(
\chapter{Appendix}
\label{app:animals}

On the fig.~\ref{fig:cat} you can see, that sizes of cats and dogs are correlated as explained in formula \eqref{eq:relation}
\begin{equation}\label{eq:relation}
2 : 3
\end{equation}

Next, suppose that beginners in small science of animal say \footnote{Regardless rank or social status}
dogs definitely bigger then cats. Well, but there is a new surprised relation? that he don't know.

As explained in \cite{towards_animals} more and more kings of gods are smallest that common cats.

More information in \url{http://www.animals.com/dogs} and \href{http://www.drawbacks.com}{Drawback}
);

ok(process_ad($ad) eq $tex, 'paragraphs');

$ad = q(
More _useful_ information on *our* web-site https://knasys.ru
);

$tex = q(
More \textit{useful} information on \textbf{our} web-site \url{https://knasys.ru}
);

ok (process_ad($ad) eq $tex, 'mixed');

done_testing();

