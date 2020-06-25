package AsciiDoc;
use strict;
use warnings FATAL => 'all';
use base 'Exporter';

our @EXPORT = qw/to_latex process_ad/;
our $VERSION = '0.02';

use Image::Size;

my %attrs;
my @rspans;
my($listenv, $tabenv, $parenv, $block, $ncols, $title, $thead, $verbenv, $bibfile);
my $sectnums = '';

sub get_width {
  my $width = 1;
  if (exists $attrs{width}) {
    $width = $attrs{width};
    $width =~ s/^(\d+)%/$1/;
    $width /= 100;
    $width =~ s/^0\./\./;
  }
  $width;
}

sub to_latex {
  $_ = shift;
  my $end = shift // '';
  s/^= (.+)/\\chapter${sectnums}{$1}/;
  s/^==(=*) (.+)/\\$1section${sectnums}{$2}/;
  while (s/\\((?:sub)?)=/\\$1sub/) {}
  if (s/^\[(?!\[)(.+?)\"?\](?!\])$//) {
    for (split /\"?,(?=\w+=)/, $1) {
      if (/(\w+)(?:=\"?(.+))?/) {
        $attrs{$1} = (defined $2) ? $2 : 1;
      }
    }
    return '';
  }
  while (s/(\[.+?)\*(.+?\])/$1\\times$2/g) {}
  if (/```(\w+)?/) {
    unless (defined $verbenv) {
      $verbenv = $1 ? 'minted' : 'verbatim';
      $_ = qq(\\begin{$verbenv}) . ($1 ? qq({$1}) : '');
    } else {
      $_ = qq(\\end{$verbenv});
      $verbenv = undef;
    }
  } elsif (s/^--$//) {
	unless (defined $block) {
		if ($attrs{abstract}) {
			delete $attrs{abstract};
			$block = 'abstract';
			if ($title) {
				$_ = qq(\\renewcommand{\\abstractname}{$title}\n);
				$title = undef;
			}
			$_ .= qq(\\begin{$block})
		}
	} else {
		$_ = qq(\\end{$block});
		$block = undef;
	}
  } elsif (s/include::?(\S+)\.\w+(\[.*\])?/\\input{$1}/) {
  } elsif (/image::?(\S+)\.(\w+)\[(.+?)(?:,float=(left|right))?\]/) {
    my $label = $1;
    $label =~ tr/\//:/;
    my ($w, $h) = imgsize(qq($1.$2));
    my $p = get_width();
    my $line_fraction = $p . '\\linewidth';
    my $width = (defined $w and $w > 600 * $p) ? qq([width=$line_fraction]) : '';
    my $graphics = ($2 eq 'tex') ? qq(\\input{$1}) : qq(\\includegraphics$width\{$1\});
    my $caption = qq(\\caption{$3}\n\\label{$label});
    my $figenv = (defined $4) ? 'wrapfigure' : 'figure';
    my $figattrs = (defined $4) ? '{' . substr($4, 0, 1) . qq|}{$line_fraction}| : '[H]';
    $_ = qq(\\begin{$figenv}$figattrs\n\\centering\n$graphics\n$caption\n\\end{$figenv});
  } elsif (/code::?([\.\w\\\/-]+\.(\w+))\[(?:lines=(\d+)\.\.(?:(\d+))?)?\]/) {
    my ($src, $lang) = ($1, $2);
	my ($pre, $post) = ('', '');
	if (exists $attrs{columns}) {
	  $pre = qq(\\begin{multicols}{$attrs{columns}}\n);
	  $post = qq(\n\\end{multicols});
	}
    my %scope = map {$_ => $attrs{$_}} grep !/^col/, sort keys %attrs;
    $scope{firstline} = $3 if (defined $3);
    $scope{lastline} = $4 if (defined $4);
    $lang =~ s/^(h|cxx|hpp)$/cpp/;
    $lang =~ s/^(txt|idl|wrl|tt2?|puml)$/text/;
    $lang =~ s/^x3d$/xml/;
    $lang =~ s/^m$/matlab/;
    my @arr = map {qq($_=$scope{$_})} keys %scope;
    my $scl = ($#arr == -1) ? '' : join(',', @arr);
    $scl =~ s/(.+)/[$1]/;
    $_ = qq($pre\\inputminted$scl\{$lang\}{$src}$post);
  } elsif (s/^latexmath::\[\s*(.+?)\s*\]\s*\[{2}([\w:]+)\]{2}/\\begin{equation}\\label{$2}\n$1\n\\end{equation}/) {
  } elsif (s/^latexmath::\[\s*(.+?)\s*\]/\$\$ $1 \$\$/) {
  } elsif (s/^:toc:$/\\tableofcontents/) {
  } elsif (s/^:toclevels: (\d+)$/\\setcounter{tocdepth}{$1}/) {
  } elsif (s/^:bibtex-file: (.+?)(?:\.bib)?$//) {
	  $bibfile = $1;
  } elsif (s/^:bibtex-style: (.+)$/\\bibliographystyle{$1}/) {
  } elsif (s/^bibliography::\[\]$/\\bibliography{$bibfile}/) {
  } elsif (s/^:toc-title: (.+)$/\\renewcommand{\\contentsname}{$1}/) {
  } elsif (s/^:bib-title: (.+)$/\\renewcommand{\\bibname}{$1}/) {
  } elsif (s/^:(\w+)num: (\d+)$/\\setcounter{$1}{$2}/) {
  } elsif (s/^:(\w+)num: \+(\d+)$/\\addtocounter{$1}{$2}/) {
  } elsif (s/^:(\w+)-caption: (.+)$/\\captionsetup[$1]{name=$2}/) {
  } elsif (s/^<<<$/\\newpage/) {
  } elsif (s/^:(!?)sectnums(!?):$//) {
	  $sectnums = ($1 or $2)? '*' : '';
  } else {
    s/\[{2}([\w:]+)\]{2}/\n\\label{$1}\n/;
    s/footnote:\[(.+?)\]/\\footnote{$1}/g;
    s/cite:\[([\w-]+)\]/\n\\cite{$1}\n/g;
    s/<<(eq:\w+?)>>/\n\\eqref{$1}\n/g;
    s/<<([\w:-]+?)>>/\n\\ref{$1}\n/g;
    s/<<([\w:-]+?),(.+?)>>/\n$2~\\ref{$1}\n/g;
    s/(https?:\S+?)(?<!\})\[(.+?)\]/\n\\href{$1}{$2}\n/g;
    s/(?<!\{)(https?:\S+)/\n\\url{$1}\n/g;
    s/(latex|ascii)math:+\[(\$?)(.+?)\g2\]/\n\$$3\$\n/g;
    s/\[(\w+line)\]#(.+?)#/\\$1\{$2\}/g;
    s/`(\S+?)`/\n\\verb|$1|\n/g;
    s/`(.+?)`/\n\\texttt{$1}\n/g;
    $_ = join '', map {chomp;
      unless (/^\$.+\$$/ or /^\\(\w+)[\{\|][\w:]+[\}\|]$/) {
	  	my @arr = split /(?<!\\)\$/, $_;
		for my $i (grep {!($_ & 1)} 0..$#arr) {
			$_ = $arr[$i];
			s/\*(.+?)\*/\\textbf{$1}/g;
			s/_(.+?)_/\\textit{$1}/g;
			s/_/\\_/g;
			$arr[$i] = $_;
		}
		$_ = join '$', @arr; 
      }
      $_} split /^/m, $_ unless (defined $verbenv);
  }
  s/[%#]/\\$&/g;
  if (s/^(-|(\d+)?\.)([-\.]*)\s/\\$3item /) {
    while (s/\\(i*)\./\\$1i/) {}
    unless (defined $listenv) {
      $listenv = ($1 eq '-') ? 'itemize' : 'enumerate';
      my $start = ($1 eq '-' or not $2) ? '' : qq([start=$2]);
      $_ = qq(\\begin{$listenv}$start\n) . $_;
    }
  } elsif (/^$/) {
    $_ = qq(\\end{$listenv}\n) if (defined $listenv);
    $listenv = undef;
	$_ = qq(\\end{$parenv}\n) if (defined $parenv);
	$parenv = undef;
    %attrs = ();
  }
  if (s/^\.([^\d\W].+)//u) {
    $title = $1;
    $_ = '';
  } elsif (/^\|=+/) {
    unless (defined $tabenv) {
      $tabenv = (exists $attrs{long}) ? 'longtabu' : 'tabu';
      my $width = get_width();
      my $caption = $title ? qq(\n\\caption{$title}) : '';
      $_ = ($tabenv =~ /^long/) ? qq(\\begin{$tabenv} to $width\\linewidth) : qq(\\begin{table}[H]$caption\n\\centering\n\\begin{$tabenv} to $width\\linewidth)
    } else {
      $_ = ($tabenv =~ /^long/) ? qq(\\hline\n\\end{$tabenv}\n) : qq(\\hline\n\\end{$tabenv}\n\\end{table}\n);
      $tabenv = undef;
      $ncols = undef;
      $title = undef;
      $thead = undef;
      @rspans = ();
      $_;
    }
  } elsif (defined $tabenv) {
    my $cols = '';
    my $caption = '';
    unless (defined $ncols) {
      $ncols = eval join '+', map {$_ or 1} /(?<!\.)(?:(\d+)(?:\.\d+)?\+)?\|+/g;
      @rspans = map {0} (1 .. $ncols);
      if (exists $attrs{cols}) {
        $cols = join '|', map {s/(?:(\d+)\*)?([<^>]?)(\.[<^>])?(\d*)\w*/$2$4/;
          my $count = $1 || 1;
          tr/<^>/lcr/;
          s/([lcr])(\d+)/X[$2,$1]/;
          s/(^\d*$)/X[$1]/;
          ($_) x $count} split(/,/, $attrs{cols});
      } else {
        $cols = join '|', map ('X', (1 .. $ncols));
      }
      $cols =~ s/(.+)/ {|$1|} /;
      $caption = qq(\n\\caption{$title} \\\\ ) if ($title and $tabenv =~ /^long/);
    }
    my $prefix = '';
    unless (defined $thead) {
      $thead = $_;
    } elsif ($thead =~ /^\|/) {
      if (/^$/ and $tabenv =~ /^long/) {
        $prefix = qq(\\endfirsthead\n\\multicolumn{$ncols}{r}{\\thetablecontinue} \\\\ \\hline\n);
        ($_, $thead) = ($thead, '');
      }
    } elsif ($thead =~ /^$/) {
      $prefix = qq(\\endhead\n\\hline\n\\endfoot\n);
      $thead = 1;
    }
    my $line = '\\hline';
    if (eval join '+', @rspans) {
      $line = '';
      my ($l, $r);
      for $r (0 .. $#rspans) {
        $l = $r + 1 if ($rspans[$r] == 0 and !defined($l));
        if ($rspans[$r] != 0 and defined($l)) {
          $line .= qq'\\cline{$l-$r}';
          undef $l;
        }
      }
      $r = $#rspans + 1;
      $line .= qq'\\cline{$l-$r}' if (defined($l));
    }
    s/^\s+//;
    my @rtemp = ();
    $_ = join ' &', map {s/^\|//;
      my ($r, $c) = (1, 1);
      if (/^(\d+)?(?:\.(\d+))?\+/) {
        $r = $2 || 1;
        $c = $1 || 1;
      }
      s/\.(\d+)(\+\|\s*)(.+)/$2\\multirow{$1}{*}{$3}/;
      s/(\d+)(\+\|\s*)(.+)/$2\\multicolumn{$1}{c|}{$3}/;
      s/\+\|//;
      while ($c-- > 0) {
        while ((my $s = shift @rspans) != 0) {
          s/^/ &/;
          push @rtemp, --$s;
        }
        push @rtemp, $r - 1;
      }
      $_} split /\s+(?=(?:[\d\.]+\+)?\|+)/, $_;
    while (scalar @rspans and (my $s = shift @rspans) != 0) {
      s/$/ &/; push @rtemp, --$s;
    }
    @rspans = @rtemp;
    $_ = $cols . $caption . qq($line\n) . $prefix . $_ . ' \\\\ ';
  } elsif ($attrs{abstract}) {
	delete $attrs{abstract};
	$parenv = 'abstract';
	qq(\\begin{$parenv}\n$_$end);
  } else {
    qq($_$end);
  }
}

sub process_ad {
  my $ad = shift;
  my $tex = '';
  for (split /^/m, $ad) {
    chomp;
	s/\s+$//;
    $tex .= to_latex($_, qq(\n));
  }
  $tex;
}

1;

__END__

=encoding utf8

=head1 NAME

AsciiDoc - convert documents from AsciiDoc to LaTeX

=head1 SYNOPSIS

  use AsciiDoc;
  # convert one line
  print to_latex('The text with _formatting_ and `code`.');

=cut
