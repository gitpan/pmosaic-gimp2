#!/usr/bin/perl -w
use strict;

use Digest::MD5;
use Test::More tests => 32;
use Test::Harness;

my $pid;
my $ofile;
my $rc_file = "./pm_state.conf";

$SIG{USR1} = 'IGNORE'; # Ignore spurious signals from child

my $tmpdir = 'img/.tmp';
my $tmpdir_was_made = 0;

if (! -d $tmpdir) {
	mkdir $tmpdir or die "$! creating temp directory.\n";
	$tmpdir_was_made++;
}

##############################################################################
# Test to completion, no interruption.
TEST1:
{
	unlink $rc_file; # Ensure no previous state
	$ofile = "img/PM__testcard";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

# Sleep until pid is no more
	snooze($pid);

# Now check for the output file and make sure it matches what is expected.
	check_output("$ofile.xcf", "$ofile.png", "img/control-testcard.png");
}

##############################################################################


##############################################################################
# Test with one interruption, then to completion.
# Make sure we're starting with a clean slate.
TEST2:
{
	unlink $rc_file; # Ensure no previous state
	$ofile = "img/PM__testcard";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);
# After some time, wake and signal the child. Super-fast machines may complete
# before the 'kill' happens! So we arrange for the child to send us a signal..
# if the envvar 'PMOSAIC_TEST_SWITCH' is set to a value, the child will send a
# USR1 signal to that value after every row is processed. So after starting
# the child, we just wait for a USR1 (and hope it came from the child!)
# This may slow processing down a little, but production runs should be done
# with the switch off.
	wait_for_sig();
	kill 'USR1' => $pid;

# Sleep until pid is no more
	snooze($pid);

# Check file was started.. there should only be one entry in the state file.
	check_state_for("$ENV{PWD}/img/testcard.png", 1);

# Restart the file, with continue, and run to completion.
	$pid = run_pmosaic("img/testcard.png",
			continue  => 1,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);
# Sleep until pid is no more
	snooze($pid);

# Now check for the output file and make sure it matches what is expected.
	check_output("$ofile.xcf", "$ofile.png", "img/control-testcard.png");

# Check the state for this file was erased.
	check_state_for("$ENV{PWD}/img/testcard.png", 0);
}

##############################################################################



##############################################################################
# Begin, interrupt, continue, interrupt, continue to completion.
TEST3:
{
	unlink $rc_file; # Ensure no previous state
	$ofile = "img/PM__testcard";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

	for (0..1) {
		wait_for_sig();
		kill 'USR1' => $pid;

# Sleep until pid is no more
		snooze($pid);

# Check file was started.. there should only be one entry in the state file.
		check_state_for("$ENV{PWD}/img/testcard.png", 1);

# Restart the file, with continue.
		$pid = run_pmosaic("img/testcard.png",
				continue  => 1,
				index     => 'pmosaic-index',
				tolerance => 1,
				state     => $rc_file,
				display   => 0,
				);
	}

# We've interrupted twice; check the file completed successfully.

# Sleep until pid is no more
	snooze($pid);

# Now check for the output file and make sure it matches what is expected.
	check_output("$ofile.xcf", "$ofile.png", "img/control-testcard.png");

# Check the state for this file was erased.
	check_state_for("$ENV{PWD}/img/testcard.png", 0);
}
##############################################################################


##############################################################################
# Begin, interrupt, and begin w/o continuing
TEST4:
{
	unlink $rc_file; # Ensure no previous state
	$ofile = "img/PM__testcard";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

	wait_for_sig();
	kill 'USR1' => $pid;

# Sleep until pid is no more
	snooze($pid);

# Check file was started.. there should only be one entry in the state file.
	check_state_for("$ENV{PWD}/img/testcard.png", 1);

# Restart the file, with no continue.
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

# Sleep until pid is no more
	snooze($pid);

# Now check for the output file and make sure it matches what is expected.
	check_output("$ofile.xcf", "$ofile.png", "img/control-testcard.png");

# Check the state for this file was erased.
	check_state_for("$ENV{PWD}/img/testcard.png", 0);
}
##############################################################################


##############################################################################
# Start file X. Interrupt. Start Y (with continue) and complete. Start X (with
# continue) and complete.
TEST5:
{
	unlink $rc_file; # Ensure no previous state
	$ofile = "img/PM__testcard";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcard.png",
			continue  => 0,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

	wait_for_sig();
	kill 'USR1' => $pid;

# Sleep until pid is no more
	snooze($pid);

# Check file was started.. there should only be one entry in the state file.
	check_state_for("$ENV{PWD}/img/testcard.png", 1);

# Now run with a different file, to completion.
	$ofile = "img/PM__testcardr";
	if (-f "$ofile.png") { unlink "$ofile.png" }
	if (-f "$ofile.xcf") { unlink "$ofile.xcf" }
	$pid = run_pmosaic("img/testcardr.png",
			continue  => 1,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

# Sleep until pid is no more
	snooze($pid);

# Check file was started.. there should only be one entry in the state file.
	check_state_for("$ENV{PWD}/img/testcardr.png", 0);

# Check an entry for the first file still exists.
	check_state_for("$ENV{PWD}/img/testcard.png", 1);


# Now run the first file again, with continue.
	$ofile = "img/PM__testcard";
	$pid = run_pmosaic("img/testcard.png",
			continue  => 1,
			index     => 'pmosaic-index',
			tolerance => 1,
			state     => $rc_file,
			display   => 0,
			);

# Sleep until pid is no more
	snooze($pid);

# Now check for the output file and make sure it matches what is expected.
	check_output("$ofile.xcf", "$ofile.png", "img/control-testcard.png");

# Check the state for this file was erased.
	check_state_for("$ENV{PWD}/img/testcard.png", 0);
}
##############################################################################

if ($tmpdir_was_made) { rmdir $tmpdir }


## End of tests

##############################################################################
### Common Functions

sub run_pmosaic
{
	my ($file, %vars) = @_;
	my $ppid = $$; # Who is to receive signals from the child?
	my $pid = fork();
	if (not defined $pid) {
		die "Oops."
	} elsif ($pid) {
		return $pid
	}
	my $arg_string = join ' ', map { "-$_ $vars{$_}" } keys %vars;
#	print"PMOSAIC_TEST_SWITCH=$ppid ../pmosaic -imgfile $file $arg_string >& /dev/null\n";
	$ENV{PMOSAIC_TEST_SWITCH} = $ppid;
	open STDOUT, ">/dev/null";
	open STDERR, ">/dev/null";
	exec("../pmosaic -imgfile $file $arg_string");
}



sub snooze
{
	my ($pid) = @_;
	return waitpid $pid, 0;
}



sub compare_files
{
	my ($test, $control) = @_;
# Used to be able to MD5 the file contents here, but GIMP 2 changed all that.
# Now we have to compare the files another way. Since we know the user has
# GIMP installed, we'll just run a program to convert the files to xpm, and
# then compare the MD5 values. 'diff' would be another possibility.
# We use a temp directory so we can write the files out with the same name -
# .xpm files embed the name of the file as the char array.
# Convert the test file to the name of the control file, so the xpm name is
# identical.
	(my $c_xpm = $control) =~ s/\.png$/.xpm/;
	(my $t_xpm = $c_xpm)   =~ s/(.*\/)/$tmpdir\//;
	convert_file($test,    $t_xpm);
	convert_file($control, $c_xpm);

	open TEST, "<$t_xpm" or return;
	if (!open CTRL, "<$c_xpm") { close TEST; return; }

	my $test_md5    = Digest::MD5->new;
	$test_md5->addfile(\*TEST);

	my $control_md5 = Digest::MD5->new;
	$control_md5->addfile(\*CTRL);
	my $ok = $control_md5->digest eq $test_md5->digest;

	close CTRL;
	close TEST;

	unlink $t_xpm;
	unlink $c_xpm;
	return $ok;
}



sub convert_file
{
	my ($from, $to) = @_;
	system("./file2file.pl", '-in' => $from, '-out' => $to); # yeah I know.
}


sub wait_for_sig
{
	my $done = 0;
	local $SIG{USR1} = sub { $done = 1 };
	while (!$done) {
		select(undef,undef,undef,0.25);
	}
}


sub check_state_for
{
	my ($file, $yesno) = @_;
	my $cnt = 0;
	my ($state, $src, $tgt, $vars) = ('') x 4;
	open FILE, "<$rc_file" or die "Failed to open $rc_file - no further tests";
	while (<FILE>) {
		chomp;
		my ($state_, $src_, $tgt_, $vars_) = split /:/;
		if ($src_ eq $file) {
			++$cnt;
			($state, $src, $tgt, $vars) = ($state_, $src_, $tgt_, $vars_);
		}
	}
	close FILE;
	if ($yesno) {
		ok($cnt == 1, "Exactly one state entry should exist, found $cnt.");
		ok(-f $tgt, "Temporary $tgt should exist.");
		return;
	}

	ok($cnt eq 0, "State entry should not exist, found $cnt.");
	ok(!($tgt || -f $tgt), "Temporary '$tgt' should be empty or not exist.");
}


sub check_output
{
	my ($from, $to, $control) = @_;
	ok(-f $from, "Output was written.");
	convert_file($from, $to);
	ok(compare_files($to, $control), "Output matches control.");
	unlink $from, $to;
}

# vim:set filetype=perl cin :
