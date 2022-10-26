#!/usr/bin/perl
# plantuml for ikiwiki: render plantuml source as an image.
# Rob Taylor, based off graphviz plugin by Josh Triplett
package IkiWiki::Plugin::plantuml;

use warnings;
use strict;
use IkiWiki 3.00;
use IPC::Open2;
use File::Basename;

sub import {
	hook(type => "getsetup", id => "plantuml", call => \&getsetup);
	hook(type => "needsbuild", id => "version", call => \&needsbuild);
	hook(type => "preprocess", id => "uml", call => \&uml, scan => 1);
	hook(type => "preprocess", id => "wbs", call => \&wbs, scan => 1);
	hook(type => "preprocess", id => "plantuml", call => \&plantuml, scan => 1);
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => undef,
			section => "widget",
		},
}


sub needsbuild {
	my $needsbuild=shift;
	foreach my $page (keys %pagestate) {
		if (exists $pagestate{$page}{uml} &&
		    exists $pagesources{$page} &&
		    grep { $_ eq $pagesources{$page} } @$needsbuild) {
			# remove state, will be re-added if
			# the uml is still there during the rebuild
			delete $pagestate{$page}{uml};
		}
		if (exists $pagestate{$page}{wbs} &&
		    exists $pagesources{$page} &&
		    grep { $_ eq $pagesources{$page} } @$needsbuild) {
			# remove state, will be re-added if
			# the wbs is still there during the rebuild
			delete $pagestate{$page}{wbs};
		}
		if (exists $pagestate{$page}{plantuml} &&
		    exists $pagesources{$page} &&
		    grep { $_ eq $pagesources{$page} } @$needsbuild) {
			# remove state, will be re-added if
			# the plantuml is still there during the rebuild
			delete $pagestate{$page}{plantuml};
		}
	}
	return $needsbuild;
}

sub render_uml (\%) {
	my %params = %{(shift)};

	my $src = $params{src};

	# Use the sha1 of the graphviz code as part of its filename,
	eval q{use Digest::SHA};
	eval q{use Encode qw(encode_utf8)};
	error($@) if $@;
	my $sha=IkiWiki::possibly_foolish_untaint(Digest::SHA::sha1_hex(encode_utf8($src)));

	my $format_info = {
		png => { ext => ".png", flag => "-tpng" },
		svg => { ext => ".svg", flag => "-tsvg" },
	};
	my $use_format = ($params{format} or 'svg');
	if (! $format_info->{$use_format}{ext}) {
		$use_format = 'svg';
	}
	my $dest=$params{page}."/uml-".$sha. $format_info->{$use_format}{ext};
	will_render($params{page}, $dest);

	$src = "$params{starttag}\n"
		. "\' ".urlto($dest, $params{destpage}) . "\n"
		. $src
		. "\n$params{endtag}\n";

	print STDERR "$src\n";
	print STDERR $config{destdir}."\n";
	print STDERR "$config{destdir}/$dest"."\n";

	#print STDERR "jar $params{jar}";

	if (! -e "$config{destdir}/$dest") {
		print STDERR "STOADT\n";
		# Use ikiwiki's function to create the image file, this makes
		# sure needed subdirs are there and does some sanity checking.
		writefile($dest, $config{destdir}, "");

		print STDERR "jar $params{jar}";
		my $pid;
		my $sigpipe=0;
		$SIG{PIPE}=sub { $sigpipe=1 };
		$pid=open2(*IN, *OUT, "java -jar $params{jar} -charset UTF-8 -pipe @{[ $format_info->{$use_format}{flag} ]} > '$config{destdir}/$dest' 2> '$config{destdir}/$dest.err'");

		# open2 doesn't respect "use open ':utf8'"
		binmode (IN, ':utf8');
		binmode (OUT, ':utf8');

		print OUT $src;
		close OUT;

		close IN;

		waitpid $pid, 0;
		$SIG{PIPE}="DEFAULT";
		# Actually, don't abort here on error because PlantUML may have generated an image with an error
		# and we want to show the error message and error image regardless of whether it already existed.
		#error gettext("failed to run java -jar $params{jar}") if ($sigpipe || $?);
	}

	my $errmsg = "";
	if (-e "$config{destdir}/$dest.err") {
		open my $fh, '<', "$config{destdir}/$dest.err" or die "failed to run java -jar $params{jar}";
		$errmsg = do { local $/; <$fh> };
		if ($errmsg ne "") {
			$errmsg = "<font color=red><pre>".CGI::escapeHTML($errmsg)."</pre></font>";
		}
	}

	my $url = urlto($dest, $params{destpage});
	if ($use_format eq "svg") {
		return $errmsg."<object data=\"$url\" type=\"image/svg+xml\"></object>";
	} else {
		return $errmsg."<img src=\"$url\" />\n";
	}
}

sub uml (@) {
	my %params=@_;
	my $key;

	#print STDERR "src = " . $params{src};
	$params{jar} = dirname($INC{"IkiWiki/Plugin/plantuml.pm"})."/plantuml.jar";
	$params{starttag} = "\@startuml";
	$params{endtag} = "\@enduml";

	return render_uml(%params);
}

sub wbs (@) {
	my %params=@_;
	my $key;

	#print STDERR "src = " . $params{src};
	$params{jar} = dirname($INC{"IkiWiki/Plugin/plantuml.pm"})."/plantuml.jar";
	$params{starttag} = "\@startwbs";
	$params{endtag} = "\@endwbs";

	return render_uml(%params);
}

sub plantuml (@) {
	my %params=@_;
	my $key;

	#print STDERR "src = " . $params{src};
	$params{jar} = dirname($INC{"IkiWiki/Plugin/plantuml.pm"})."/plantuml.jar";

	return render_uml(%params);
}

1
