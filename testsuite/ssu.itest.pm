#! /usr/bin/perl
#
# ssu.itest.pm
# Perl module for integrated tests of the SSU-ALIGN scripts.
#
# EPN, Tue Mar 16 14:33:46 2010

use strict;
use warnings;

#####################################################
sub run_mask { 
    if(scalar(@_) != 4) { die "TEST SCRIPT ERROR: run_mask called with " . scalar(@_) . " != 4 arguments."; }
    my ($ssumask, $dir, $extra_opts, $testctr) = @_;
    my $command;
    if($extra_opts ne "") { $command = "$ssumask $extra_opts $dir > /dev/null"; }
    else                  { $command = "$ssumask $dir > /dev/null"; }
    printf("Running  mask command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask $testctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_align { 
    if(scalar(@_) != 5) { die "TEST SCRIPT ERROR: run_align called with " . scalar(@_) . " != 5 arguments."; }
    my ($ssualign, $fafile, $dir, $extra_opts, $testctr) = @_;
    my $command;
    if($extra_opts ne "") { $command = "$ssualign $extra_opts $fafile $dir > /dev/null"; }
    else                  { $command = "$ssualign $fafile $dir > /dev/null"; }
    printf("Running align command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align $testctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_build { 
    if(scalar(@_) != 4) { die "TEST SCRIPT ERROR: run_build called with " . scalar(@_) . " != 4 arguments."; }
    my ($ssubuild, $stk, $extra_opts, $testctr) = @_;
    my $command;
    $command = "$ssubuild $extra_opts $stk > /dev/null"; 
    printf("Running build command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-build $testctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_draw {
    if(scalar(@_) != 4) { die "TEST SCRIPT ERROR: run_draw called with " . scalar(@_) . " != 4 arguments."; }
    my ($ssudraw, $dir, $extra_opts, $testctr) = @_;
    my $command;
    if($extra_opts ne "") { $command = "$ssudraw $extra_opts $dir > /dev/null"; }
    else                  { $command = "$ssudraw $dir > /dev/null"; }
    printf("Running  draw command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-draw $testctr failed unexpectedly"; }
    return;
}
#####################################################
# check_for_files: Check if <dir>/<dir>.<name>.<suffix> exists
#                  for each <name> in $name_AR. Die if any do not exist.
sub check_for_files {
    if(scalar(@_) != 5) { die "TEST SCRIPT ERROR: check_for_files called with " . scalar(@_) . " != 5 arguments."; }
    my ($dir, $root, $testctr, $name_AR, $suffix) = @_;
    my ($name, $file);
    foreach $name (@{$name_AR}) { 
	if($root ne "") { $file = $dir . "/" . $root . "." . $name . $suffix; }
	else            { $file = $dir . "/" . $name . $suffix; }
	if(! -e $file) { die "FAIL: ssu-mask $testctr call failed to create file $file"; }
    }
    return;
}
#####################################################
# check_for_one_of_two_files: Check if <dir>/<dir>.<name>.<suffix1> OR <dir>/<dir>.<name>.<suffix2> 
#                             exists for each <name> in $name_AR. Die if neither exist for any <name>.
sub check_for_one_of_two_files {
    if(scalar(@_) != 6) { die "TEST SCRIPT ERROR: check_for_one_of_two_files called with " . scalar(@_) . " != 6 arguments."; }
    my ($dir, $root, $testctr, $name_AR, $suffix1, $suffix2) = @_;
    my ($file1, $file2, $name);
    foreach $name (@{$name_AR}) { 
	if($root ne "") { 
	    $file1 = $dir . "/" . $root . "." . $name . $suffix1; 
	    $file2 = $dir . "/" . $root . "." . $name . $suffix2;
	}
	else {
	    $file1 = $dir . "/" . $name . $suffix1; 
	    $file2 = $dir . "/" . $name . $suffix2;
	}
	if((! -e $file1) && (! -e $file2)) { die "FAIL: ssu-mask $testctr call failed to create either file $file1 or file $file2"; }
    }
    return;
}
#####################################################
# remove_files: Remove files that match string <str> in dir <dir>
sub remove_files {
    if(scalar(@_) != 2) { die "TEST SCRIPT ERROR: remove_files called with " . scalar(@_) . " != 2 arguments."; }
    my ($dir, $str) = @_;
    my $file;
    if(! -d $dir) { return; }
    foreach $file (glob("$dir/*")) { 
	if($file =~ m/$str/) { unlink $file || die "TEST SCRIPT ERROR, unable to remove file $file in $dir"; }
    }
    return;
}
####################################################################
# the next line is critical, a perl module must return a true value
return 1;
####################################################################

