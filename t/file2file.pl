#!/usr/bin/perl
# No warnings - otherwise it gripes about 'gimp_file_load' etc being
# redefined.

#	(C) Simon Drabble	2004-06-21
#	gimp@thebigmachine.org
#	$Id$
#



use Gimp ":auto";
use Gimp::Fu;

# This is a quick'n'dirty script to convert a file to an xpm, for the purposes
# of testing pmosaic out. It is not intended to be used as anything more
# than that.

use strict;

sub file2file_run
{
	my ($in, $out) = @_;
	my $img = gimp_file_load($in, $in); 
# Older versions of gimp_file_save() require $Gimp::Fu::runmode..
	gimp_file_save($img, $img->get_active_layer, $out, $out);
}



register
	"perl_fu_file2file",                               # fill in name
	"Converts a file to another format.",             # a small description
	qq{Cheap'n'cheerful script to convert file formats.}, # a help text
	"Simon Drabble <gimp\@thebigmachine.org>",         # Your name
	"(c) Simon Drabble <gimp\@thebigmachine.org>",     # Your copyright
	"2004/08/12",                                      # Date
# Doesn't matter - not intended to be run from inside the GIMP explicitly.
	"<Toolbox>/Xtns/Perl-Fu/pmosaic",               # menu path
	"*",                                               # Image types
	[
		[PF_FILE,   "in",   "Input File",                                 ""],
		[PF_FILE,   "out",  "Output File",                                ""],
	],
	\&file2file_run;

exit main();


__END__
