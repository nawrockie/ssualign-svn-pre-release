#!/usr/bin/perl
#
# ssu-align-0p1.subs.pm
# Eric Nawrocki
# EPN, Thu Nov  5 05:39:37 2009
#
# Perl module used by SSU-ALIGN v0.1 perl scripts. This module
# contains subroutines called by > 1 of the SSU-ALIGN perl scripts.
#
# List of subroutines in this file:
#
# PrintBanner():                   prints SSU-ALIGN banner given a script description.
# PrintConclusion():               prints final lines of SSU-ALIGN script output
# PrintTiming():                   prints run time to stdout and summary file.
# PrintStringToFile():             prints string to a file and optionally stdout.
# RunExecutable():                 runs an executable with backticks, returns output.
# UnlinkFile():                    unlinks a file, and updates log file.
# DetermineNumSeqsFasta():         determine the number of sequences in a FASTA file.
# DetermineNumSeqsStockholm():     determine the number of sequences in a Stockholm aln file.
# ArgmaxArray():                   determine the index of the max value scalar in an array
# MaxLengthScalarInArray():        determine the max length scalar in an array.
# SumArrayElements():              return sum of values in a numeric array
# SumHashElements():               return sum of values in a numeric hash 
# TryPs2Pdf():                     attempt to run 'ps2pdf' to convert ps to pdf file.
# SwapOrAppendFileSuffix():        given a file name, return a new name with a suffix swapped.
# RemoveDirPath():                 remove the leading directory path of a filename
# CheckForModule():                check if a particular module is installed on the system
# SecondsSinceEpoch():             return number of seconds since the epoch 
# FileOpenFailure():               called if an open() call fails, print error msg and exit
# PrintErrorAndExit():             print an error message and call exit to kill the program
# PrintSearchAndAlignStatistics(): print ssu-align summary statistics on search and alignment
#
use strict;
use warnings;


#####################################################################
# Subroutine: PrintBanner()
# Incept:     EPN, Thu Sep 24 14:40:39 2009
# 
# Purpose:    Print the ssu-mask banner.
#
# Arguments: 
#    $script_call:      call used to invoke this (ssu-draw) script
#    $script_desc:      short description of script, printed to stdout
#    $date:             date to print
#    $opt_HR:           REFERENCE to hash of command-line options
#    $opt_takes_arg_HR: REFERENCE to hash telling if each option takes an argument (1) or not (0)
#    $opt_order_AR:     REFERENCE to array specifying order of options
#    $argv_R:           REFERENCE to @ARGV, command-line arguments
#    $print_to_stdout:  '1' to print to stdout, '0' not to
#    $out_file:         file to print to, "" for not any file
#
# Returns:    Nothing, if it returns, everything is valid.
# 
####################################################################
sub PrintBanner { 
    my $narg_expected = 9;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintBanner() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($script_call, $script_desc, $date, $opt_HR, $opt_takes_arg_HR, $opt_order_AR, $argv_R, $print_to_stdout, $out_file) = @_;

    my ($i, $script_name, $start_log_line, $opt);
    $script_call =~ s/^\.+\///;
    $script_name = $script_call;
    $script_name =~ s/.+\///;
    my $enabled_options = "";
    foreach $opt (@{$opt_order_AR}) { 
	if($opt_takes_arg_HR->{$opt}) { if($opt_HR->{$opt} ne "") { $enabled_options .= " " . $opt . " " . $opt_HR->{$opt}; } }
	else                  	      { if($opt_HR->{$opt})       { $enabled_options .= " " . $opt; } }
    }

    $script_call =~ s/^\.+\///;
    $script_name = $script_call;
    $script_name =~ s/.+\///;

    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# $script_name :: $script_desc\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# SSU-ALIGN 0.1 (October 2009)\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# Copyright (C) 2009 HHMI Janelia Farm Research Campus\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# Freely distributed under the GNU General Public License (GPLv3)\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("%-10s %s ", "# command:", $script_call . $enabled_options));
    for($i = 0; $i < (scalar(@{$argv_R}) - 1); $i++) { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("%s ", $argv_R->[$i]));
    }
    if(scalar(@{$argv_R}) > 0) { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("%s\n", $argv_R->[(scalar(@{$argv_R})-1)])); 
    }
    else { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("\n"));
    }
    PrintStringToFile($out_file, $print_to_stdout, sprintf("%-10s ", "# date:"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf($date));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\n"));

    return;
}


#######################################################################
# Subroutine: PrintConclusion()
# Incept:     EPN, Thu Nov  5 18:25:31 2009
# 
# Purpose:    Print the final few lines of output and optionally the 
#             run time timing to the summary file. Print date and
#             system information to the log file.
#
# Arguments: 
#    $sum_file:               full path to summary file
#    $log_file:               full path to log file
#    $sum_file2print:         name of summary file
#    $log_file2print:         name of log file
#    $total_time:             total number of seconds, "" to not print timing
#    $time_hires_installed: '1' if Time:HiRes is installed (we'll print milliseconds)
#    $out_dir:                output directory where output files were put,
#                             "" if it is current dir.
#
# Returns:    Nothing.
# 
####################################################################
sub PrintConclusion { 
    my $narg_expected = 7;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintConclusion() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($sum_file, $log_file, $sum_file2print, $log_file2print, $total_time, $time_hires_installed, $out_dir) = @_;

    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    #PrintStringToFile($sum_file, 1, sprintf("# Commands executed by this script written to log file:  $log_file2print.\n"));
    #PrintStringToFile($sum_file, 1, sprintf("# This output printed to screen written to summary file: $sum_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("# List of executed commands saved in:     $log_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("# Output printed to the screen saved in:  $sum_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    if($out_dir ne "") { 
	PrintStringToFile($sum_file, 1, sprintf("# All output files created in directory \.\/%s\/\n", $out_dir));
	PrintStringToFile($sum_file, 1, sprintf("#\n"));
    }
    else { 
	PrintStringToFile($sum_file, 1, sprintf("# All output files created in the current working directory.\n"));
	PrintStringToFile($sum_file, 1, sprintf("#\n"));
    }
    if($total_time ne "") { 
	PrintTiming("# CPU time: ", $total_time, $time_hires_installed, 1, $sum_file); 
	PrintStringToFile($sum_file, 1, sprintf("# \n"));
    }
    PrintStringToFile($log_file, 0, `date`);
    PrintStringToFile($log_file, 0, `uname -a`);

    return;
}


#####################################################################
# Subroutine: PrintTiming()
# Incept:     EPN, Tue Jun 16 08:52:08 2009
# 
# Purpose:    Print a timing in hhhh:mm:ss format to 1 second precision.
# 
# Arguments:
# $prefix:                 string to print before the hhhh:mm:ss time info.
# $inseconds:              number of seconds
# $time_hires_installed: '1' if Time:HiRes is installed (we'll print milliseconds)
# $print_to_stdout:        '1' to print to stdout, '0' not to
# $sum_file:               file to print output file notices to
#
# Returns:    Nothing, if it returns, everything is valid.
# 
####################################################################
sub PrintTiming { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, print_timing() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($prefix, $inseconds, $time_hires_installed, $print_to_stdout, $sum_file) = @_;
    my ($i, $hours, $minutes, $seconds, $thours, $tminutes, $tseconds);

    $hours = int($inseconds / 3600);
    $inseconds -= ($hours * 3600);
    $minutes = int($inseconds / 60);
    $inseconds -= ($minutes * 60);
    $seconds = $inseconds;
    $thours   = sprintf("%02d", $hours);
    $tminutes = sprintf("%02d", $minutes);
    if($time_hires_installed) { 
	$tseconds = sprintf("%05.2f", $seconds);
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("%s %2s:%2s:%5s\n", $prefix, $thours, $tminutes, $tseconds));
    }
    else { 
	$tseconds = sprintf("%02d", $seconds);
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("%s %2s:%2s:%2s\n", $prefix, $thours, $tminutes, $tseconds));
    }
}


###########################################################
# Subroutine: PrintStringToFile()
# Incept: EPN, Thu Oct 29 10:47:25 2009
#
# Purpose: Given a string and a file name, append the 
#          string to the file, and potentially to stdout
#          as well. If $filename is the empty string,
#          don't print to a file. 
#
# Returns: Nothing. If the file can't be written to 
#          an error message is printed and the program
#          exits.
#
###########################################################
sub PrintStringToFile {
    my $narg_expected = 3;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintStringToFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($filename, $print_to_stdout, $string) = @_;

    if($filename ne "") { 
	open(OUT, ">>" . $filename) || die "ERROR, couldn't open $filename for appending.\n";
	printf OUT $string;
	close(OUT);
    }

    if($print_to_stdout) { printf($string); }
    return;
}


###########################################################
# Subroutine: RunExecutable
# Incept: EPN, Fri Oct 30 06:05:37 2009
#
# Purpose: Run a command with backticks, capturing its standard
#          output and standard error. Print command execution
#          and its output to $log_file. If command returns 
#          non-zero status, print error message $errmsg to 
#          STDERR, and exit if $die_if_fails is TRUE. 
#
# Arguments:
#   $command:                   command to execute
#   $die_if_fails:              '1' to die if command returns non-zero status
#   $print_output_upon_failure: '1' to print command output to STDERR if it fails
#   $log_file:                  file to print command and output to
#   $command_worked_ref:        set to '1' if command works (returns 0), else set to '0'         
#   $errmsg:                    message to print if command returns non-0 exit status
# 
# Returns: Output (stdout and stderr) of the command.
#
###########################################################
sub RunExecutable {
    my $narg_expected = 6;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RunExecutable() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($command, $die_if_fails, $print_output_upon_failure, $log_file, $command_worked_ref, $errmsg) = @_;

    #contract check
    if(($die_if_fails) && ($errmsg eq "")) { die "ERROR, misuse of RunExecutable: errmsg is the empty string and die_if_fails is TRUE."; }
    my $output = "";
    my $command_worked = 1;

    my $output_file = "";
    # determine if we're piping output to a file (or /dev/null)
    if($command =~ m/\>\s*(\S+)\s*$/) { 
	$output_file = $1;
    }

    # redirect stderr to stdout
    if($command !~ m/2\>\&1\s*$/) { 
	$command .= " 2>&1"; 
    }

    PrintStringToFile($log_file, 0, ("Executing:  " . $command . "\n"));
    $output = `$command`;

    PrintStringToFile($log_file, 0, ("Returned:   " . ($? >> 8) . "\n"));

    if(($? >> 8) != 0) { 
	if($output_file ne "") { 
	    my $line;
	    $output = "";
	    open(OUTFILE, $output_file) || die "\nERROR, couldn't open recently created output file $output_file for reading.\n";
	    while($line = <OUTFILE>) { $output .= $line; }
	    close(OUTFILE);
	}
	if($errmsg ne "") { 
	    if(($output_file ne "") && ($output_file !~ /dev\/null/)) { 
		PrintStringToFile($log_file, 0, ("Output (in output file $output_file):\n" . $output . "\n\n"));
	    }
	    else { 
		PrintStringToFile($log_file, 0, ("Output:     " . $output . "\n\n"));
	    }
	    printf STDERR ("\n$errmsg\n");
	    PrintStringToFile($log_file, 0, ("\n$errmsg\n"));
	}
	if($print_output_upon_failure) { printf STDERR ("Command output: $output\n"); }
	if($die_if_fails) { exit(1); }
	$command_worked = 0;
    }
    else { 
	PrintStringToFile($log_file, 0, ("Output:     " . $output . "\n\n"));
    }

    $$command_worked_ref = $command_worked;
    return $output;
}


###########################################################
# Subroutine: UnlinkFile()
# Incept: EPN, Wed Nov  4 18:19:29 2009
#
# Purpose: Unlink (remove) a file. Print info to log file 
#          saying it's been unlinked. 
#
# Returns: Nothing. If the file can't be unlinked, we die.
#
###########################################################
sub UnlinkFile {
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, UnlinkFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file, $log_file) = @_;

    PrintStringToFile($log_file, 0, ("About to remove file ($file) with perl's unlink function ... "));
    if(! unlink($file)) { 
	PrintStringToFile($log_file, 0, ("ERROR, couldn't unlink it."));
	die "\nERROR, couldn't remove file $file with unlink function.\n";
    }
    PrintStringToFile($log_file, 0, ("done.\n\n"));
    
    return;
}


#####################################################################
# Subroutine: DetermineNumSeqsFasta()
# Incept:     EPN, Mon Nov  3 15:18:52 2008
# 
# Purpose:    Count the number of sequences in the fasta file 
#             <$fasta_file>.
#
# Arguments: 
# $fasta_file: the target sequence file (FASTA format)
#
# 
# Returns:    Number of sequences in FASTA file <$fasta_file>. 
#             -1 if first non-whitespace character is not a '>',
#             in this case <$fasta_file> is not legal FASTA.
# 
####################################################################
sub DetermineNumSeqsFasta { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, determine_num_seqs() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file) = $_[0];

    my $nseq = 0;
    my $line;
    if(!(-e $file)) { printf STDERR ("ERROR, determine_num_seqs(), file $file does not exist.\n"); exit(1); }
    open(IN, $file) || die "ERROR, couldn't open file $file to determine the number of sequences within it.\n"; 
    #find first '>'
    while(($nseq == 0) && ($line = <IN>)) { 
	if($line =~ m/^\>/)   { $nseq++; }
	elsif($line =~ m/\W/) { return -1; } # ERROR, first non-whitespace character is not '>', this is not valid FASTA
    }
    while($line = <IN>) { 
	if($line =~ m/^\>/) { $nseq++; }
    }
    close(IN);
    return $nseq;
}


#####################################################################
# Subroutine: DetermineNumSeqsStockholm()
# Incept:     EPN, Thu Nov  5 11:44:34 2009
# 
# Purpose:    Use esl-seqstat to determine the number of sequences
#             in a the first alignment of a Stockholm file.
#
# Arguments: 
#   $seqstat:   path and name of ssu-esl-seqstat executable
#   $alifile:   Stockholm sequence file
#   $log_file:  log file to print commands to
#   $nseq_AR:   reference to array to fill with num seqs for each
#               alignment in $alifile
#   $nali_R:    reference to scalar to 
#
# 
# Returns:    Nothing. 
#             Number of sequences in each alignment will be filled
#             in @{$nseq_AR}, with $nali_R elements.
# 
####################################################################
sub DetermineNumSeqsStockholm { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("\nERROR, DetermineNumSeqsStockholm() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my($seqstat, $alifile, $log_file, $nseq_AR, $nali_R) = @_;

    my ($nseq, $command, $line, $command_worked, $output);
    $command = "$seqstat $alifile";
    $output = RunExecutable("$command", 1, 1, $log_file, \$command_worked, "ERROR, the command \(\"$command\"\) unexpectedly returned non-zero exit status.");

    my @tmp_A = split("\n", $output);
    my $nali = 0;
    foreach $line (@tmp_A) { 
	if($line =~ /Number of sequences\:\s+(\d+)/) { 
	    $nseq = $1;
	    push(@{$nseq_AR}, $nseq);
	    $nali++;
	}
    }
    if($nali == 0) { die "\nERROR parsing esl-seqstat output, couldn't determine number of sequences in $alifile.\n" }

    $$nali_R = $nali;
    return;
}


#################################################################
# Subroutine : ArgmaxArray()
# Incept:      EPN, Tue Nov  4 14:33:23 2008
# 
# Purpose:     Return the index of the max value in an array.
#
# Arguments:
# $arr_R: reference to the array
# 
# Returns:     The index of the max value in the array.
#
################################################################# 
sub ArgmaxArray
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, ArgmaxArr() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];
    if(scalar(@{$arr_R}) == 0) { printf STDERR ("ERROR, ArgmaxArr() called with empty array."); exit(1); }

    my ($max, $i, $argmax);

    $max = $arr_R->[0];
    $argmax = 0;
    for($i = 1; $i < scalar(@{$arr_R}); $i++) { 
	if($arr_R->[$i] > $max) { $max = $arr_R->[$i]; $argmax = $i; }
    }
    return $argmax;
}


#################################################################
# Subroutine : MaxLengthScalarInArray()
# Incept:      EPN, Tue Nov  4 15:19:44 2008
# 
# Purpose:     Return the maximum length of a scalar in an array
#
# Arguments: 
#   $arr_R: reference to the array
# 
# Returns:     The length of the maximum length scalar.
#
################################################################# 
sub MaxLengthScalarInArray {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, MaxLengthScalarInArray() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];

    my ($max, $i);
    $max = length($arr_R->[0]);
    for($i = 1; $i < scalar(@{$arr_R}); $i++) { 
	if(length($arr_R->[$i]) > $max) { $max = length($arr_R->[$i]); }
    }
    return $max;
}


#################################################################
# Subroutine : SumArrayElements()
# Incept:      EPN, Wed Nov 11 16:59:26 2009
# 
# Purpose:     Return the sum of all elements in a numeric array.
#
# Arguments:
# $arr_R: reference to the array
# 
# Returns:     The sum.
#
################################################################# 
sub SumArrayElements 
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SumArrayElements() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];

    my $nels = scalar(@{$arr_R}); 
    my $sum = 0.;
    my $i;

    for($i = 1; $i < $nels; $i++) { $sum += $arr_R->[$i]; } 
    return $sum;
}


#################################################################
# Subroutine : SumHashElements()
# Incept:      EPN, Wed Nov 11 17:01:19 2009
# 
# Purpose:     Return the sum of all elements in a numerich hash.
#
# Arguments:
# $hash_R: reference to the hash
# 
# Returns:     The sum.
#
################################################################# 
sub SumHashElements 
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SumHashElements() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($hash_R) = $_[0];

    my $key;
    my $sum = 0.;
    foreach $key (keys %{$hash_R}) { $sum += $hash_R->{$key}; }

    return $sum;
}


#################################################################
# Subroutine : TryPs2Pdf
# Incept:      EPN, Fri Nov  6 05:50:40 2009
# 
# Purpose:     Try running $ps2pdf command to convert a postscript 
#              file into a pdf file. If $ps2pdf == "", use command
#              'ps2pdf', else use $ps2pdf. 
# Arguments: 
#   $ps2pdf:                    command to execute, if "", use 'ps2pdf'
#   $ps_file:                   postscript file
#   $pdf_file:                  pdf file to create
#   $die_if_fails:              '1' to die if command returns non-zero status
#   $print_output_upon_failure: '1' to print command output to STDERR if it fails
#   $log_file:                  file to print command and output to
#   $command_worked_ref:        set to '1' if command works (returns 0), else set to '0'         
#   $errmsg:                    message to print if command returns non-0 exit status
# 
# Returns:     The output of $ps2pdf. $command_worked_ref is filled with
#              '1' if command worked (return 0), '0' otherwise.
#
################################################################# 
sub TryPs2Pdf {
    my $narg_expected = 8;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, TryPs2Pdf() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($ps2pdf, $ps_file, $pdf_file, $die_if_fails, $print_output_upon_failure, $log_file, $command_worked_ref, $errmsg) = @_;

    # contract check
    if(! (-e $ps_file)) { die "\nERROR, in TryPs2Pdf(), ps file $ps_file doesn't exist.\n"; }

    my $command_worked;
    # Change the following line to change the default ps2pdf command
    if($ps2pdf eq "") { $ps2pdf = "ps2pdf"; }

    my $command = "$ps2pdf $ps_file $pdf_file";
    my $output = RunExecutable("$command", $die_if_fails, $print_output_upon_failure, $log_file, \$command_worked, $errmsg);

    $$command_worked_ref = $command_worked;
    return $output;
}



#################################################################
# Subroutine : SwapOrAppendFileSuffix
# Incept:      EPN, Mon Nov  9 14:21:07 2009# 
#
# Purpose:     Given a file name, possible original suffixes it may 
#              have (such as '.stk', '.sto'), and a new suffix: 
#              if the name has any of the original suffixes replace them
#              with the new one, else simply append the new suffix.
#              Also, if <$use_orig_dir> == 1, then include
#              the same dir path to the new file, else remove
#              the dir path (in this case, it is assumed that we
#              want the new file in the CWD.
#
# Arguments: 
#   $orig_file:       name of original file
#   $orig_suffix_AR:  reference to array of original suffixes 
#   $new_suffix:      new suffix to include in new file
#   $use_orig_dir: '1' to place new file in same dir as old one
#                     '0' to always place new file in CWD.
# 
# Returns:     The name of the new file, with $new_suffix appended
#              or swapped.
#
################################################################# 
sub SwapOrAppendFileSuffix() {
    my $narg_expected = 4;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SwapOrAppendFileSuffix() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($orig_file, $orig_suffix_AR, $new_suffix, $use_orig_dir) = @_;

    my $new_file = $orig_file;
    my $suffix;
    my $did_swap = 0;
    foreach $suffix (@{$orig_suffix_AR}) { 
	if($new_file =~ s/$suffix$/$new_suffix/) { $did_swap = 1; last; } #only remove final suffix (if ".stk.sto", remove only ".sto")
    }
    if(! $did_swap) { # we couldn't find one of the orig suffixes in @{$orig_suffix_AR}, append $new_suffix
	$new_file .= $new_suffix;
    }
    if(! $use_orig_dir) { 
	$new_file = RemoveDirPath($new_file); # remove dir path
    }
    return $new_file;
}


#################################################################
# Subroutine : RemoveDirPath()
# Incept:      EPN, Mon Nov  9 14:30:59 2009
#
# Purpose:     Given a file name remove the directory path.
#              For example: "foodir/foodir2/foo.stk" becomes "foo.stk".
#
# Arguments: 
#   $orig_file: name of original file
# 
# Returns:     The string $orig_file with dir path removed.
#
################################################################# 
sub RemoveDirPath() {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RemoveDirPath() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $orig_file = $_[0];

    $orig_file =~ s/^.+\///;
    return $orig_file;
}


#################################################################
# Subroutine : CheckForModule()
# Incept:      EPN, Tue Nov 10 17:36:16 2009
#
# Purpose:     Check to see if we have a given module installed
#              on the system.
#
# Arguments: 
#   $module: name of module to check for (ex: "Time::HiRes")
# 
# Returns:     '1' if module is installed, '0' if not.
#
################################################################# 
sub CheckForModule() { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, CheckForModule() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $module = $_[0];

    eval "require $module";
    if ($@) { return 0; }
    else    { return 1; }
}



#################################################################
# Subroutine : SecondsSinceEpoch()
# Incept:      EPN, Tue Nov 10 17:38:11 2009
#
# Purpose:     Return number of seconds since the epoch, this
#              will be different precision depending on if
#              <$time_hires_installed>.
#
# Arguments: 
#   $time_hires_installed: '1' if we can use gettimeofday
#                          to get high precision timings.
# 
# Returns:     Number of seconds since the epoch.
#
################################################################# 
sub SecondsSinceEpoch() { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, GetSecondsSinceEpoch() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $time_hires_installed = $_[0];

    if($time_hires_installed) { 
	my ($seconds, $microseconds) = gettimeofday();
	return ($seconds + ($microseconds / 1000000.));
    }
    else { # this will be one-second precision
	return time();
    }
}


#################################################################
# Subroutine : FileOpenFailure()
# Incept:      EPN, Wed Nov 11 05:39:56 2009
#
# Purpose:     Called if a open() call fails on a file.
#              Print an informative error message
#              to <$out_file> and to STDERR, then exit with
#              <$status>.
#
# Arguments: 
#   $file_to_open: file that we couldn't open
#   $out_file:     file to write errmsg to, "" for none
#   $status:       error status
#   $action:       "reading", "writing", "appending"
# 
# Returns:     Nothing, this function will exit the program.
#
################################################################# 
sub FileOpenFailure() { 
    my $narg_expected = 4;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, FileOpenForReadingFailure() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file_to_open, $out_file, $status, $action) = @_;

    my $errmsg;
    if(($action eq "reading") && (! (-e $file_to_open))) { 
	$errmsg = "\nERROR, could not open $file_to_open for reading. It does not exist.\n";
    }
    else { 
	$errmsg = "\nERROR, could not open $file_to_open for $action.\n";
    }
    PrintErrorAndExit($errmsg, $out_file, $status);
}


#################################################################
# Subroutine : PrintErrorAndExit()
# Incept:      EPN, Wed Nov 11 06:22:59 2009
#
# Purpose:     Print an error message to STDERR and optionally
#              to a file, then exit with return status <$status>.
#
# Arguments: 
#   $errmsg:       the error message to write
#   $out_file:     file to write errmsg to, "" for none
#   $status:       error status to exit with
# 
# Returns:     Nothing, this function will exit the program.
#
################################################################# 
sub PrintErrorAndExit() { 
    my $narg_expected = 3;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintErrorAndExit() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($errmsg, $out_file, $status) = @_;

    if($errmsg !~ m/\n$/) { $errmsg .= "\n\n"; }
    else                  { $errmsg .= "\n"; }
    if($errmsg !~ m/^\n/) { $errmsg = "\n" . $errmsg; }

    if($out_file ne "") { 
	PrintStringToFile($out_file, 0, $errmsg);
    }
    printf STDERR $errmsg; 
    exit($status);
}



#####################################################################
# Subroutine: PrintSearchAndAlignStatistics()
# Incept:     EPN, Thu Nov 12 05:40:53 2009
# 
# Purpose:    Print statistics on the search and alignment we just 
#             performed to the summary file and stdout.
#
# Arguments: 
# $search_seconds:       seconds required for search
# $align_seconds:        seconds required for alignment
# $target_nseq:          number of sequences in input target file
# $target_nres:          number of residues in input target file
# $nseq_all_cms:         number of sequences that were best match to any CM
# $nres_total_all_cms:   summed length of all target seqs that were best 
#                        match to any CM
# $nres_aligned_all_cms: summed length of extracted and aligned target seqs 
#                        that were best match to any CM
# $indi_cm_name_AR:      reference to array with CM names
# $nseq_cm_HR:           number of sequences that were best match to each CM 
# $nres_total_cm_HR:     summed length of target seqs that were best match to each CM
# $nres_aligned_cm_HR:   summed length of extracted and aligned target seqs that 
#                        were best match to each CM
# $print_to_stdout:      '1' to also print to stdout (in addition to <$sum_file>)
# $sum_file:             summary file 
# 
# Returns:    Nothing.
#             
# 
####################################################################
sub PrintSearchAndAlignStatistics { 
    my $narg_expected = 13;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintSearchAndAlignStatistics() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($search_seconds, $align_seconds, $target_nseq, $target_nres, $nseq_all_cms, $nres_total_all_cms, $nres_aligned_all_cms, 
	$indi_cm_name_AR, $nseq_cm_HR, $nres_total_cm_HR, $nres_aligned_cm_HR, $print_to_stdout, $sum_file) = @_;

    my ($cm_name, $i);

    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# Summary statistics:\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));

    my $cm_width = MaxLengthScalarInArray($indi_cm_name_AR);
    if($cm_width < length("*all models*")) { $cm_width = length("*all models*"); }
    my $dashes = ""; for($i = 0; $i < $cm_width; $i++) { $dashes .= "-"; } 
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s\n", $cm_width, "model or",   "number",  "fraction", "average",        "average"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s\n", $cm_width, "category",   "of seqs", "of total", "length",         "coverage"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s\n", $cm_width, $dashes,      "-------", "--------", "-------------",  "--------"));
    
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f\n", 
							   $cm_width, "*input*", 
							   $target_nseq,
							   1.0, 
							   $target_nres / $target_nseq,
							   1.0));
    foreach $cm_name (@{$indi_cm_name_AR}) { 
	if($nseq_cm_HR->{$cm_name} == 0) { 
	    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13s  %8s\n", 
								   $cm_width, $cm_name, 
								   $nseq_cm_HR->{$cm_name},
								   $nseq_cm_HR->{$cm_name} / $target_nseq,
								   "-", "-"));
	}
	else { 
	    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f\n", 
								   $cm_width, $cm_name, 
								   $nseq_cm_HR->{$cm_name},
								   $nseq_cm_HR->{$cm_name} / $target_nseq,
								   $nres_aligned_cm_HR->{$cm_name} / $nseq_cm_HR->{$cm_name}, 
								   $nres_aligned_cm_HR->{$cm_name} / $nres_total_cm_HR->{$cm_name}));
	}
    }
    #if($nseq_all_cms == 0) { PrintErrorAndExit("ERROR, no seqs matched to any CM (during stat printing). Program should've exited earlier. Error in code.", $sum_file, 1); }
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f\n", 
							   $cm_width, "*all models*", 
							   $nseq_all_cms,
							   $nseq_all_cms / $target_nseq,
							   $nres_aligned_all_cms / $nseq_all_cms, 
							   $nres_aligned_all_cms / $nres_total_all_cms));
    if($target_nseq > $nseq_all_cms) { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8s\n", 
							       $cm_width, "*no models*", 
							       $target_nseq - $nseq_all_cms,
							       ($target_nseq - $nseq_all_cms) / $target_nseq,
							       ($target_nres - $nres_total_all_cms) / ($target_nseq - $nseq_all_cms),
							       "-"));
    }
    else { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13s  %8s\n", 
							       $cm_width, "*no models*", 
							       $target_nseq - $nseq_all_cms,
							       0., "-", "-"));
    }
    
    if($search_seconds eq "0") { $search_seconds = 1; }
    if($align_seconds eq "0") { $align_seconds = 1; }
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# Speed statistics:\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-9s  %8s  %7s  %13s  %13s  %8s\n","stage",     "num seqs", "seq/sec", "seq/sec/model", "nucleotides",   "nt/sec"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %9s  %8s  %7s  %13s  %13s  %8s\n", "---------", "--------", "-------", "-------------", "-------------", "--------"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-9s  %8d  %7.3f  %13.3f  %13d  %8.1f\n", 
							   "search", $target_nseq, 
							   ($target_nseq / $search_seconds), 
							   ($target_nseq / ($search_seconds * scalar(@{$indi_cm_name_AR}))), 
							   $target_nres, 
							   $target_nres / $search_seconds));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-9s  %8d  %7.3f  %13.3f  %13d  %8.1f\n", 
							   "alignment", $nseq_all_cms, 
							   ($nseq_all_cms / $align_seconds), 
							   ($nseq_all_cms / $align_seconds), 
							   $nres_aligned_all_cms, 
							   $nres_aligned_all_cms / $align_seconds));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));

    return;
}

####################################################################
# the next line is critical, a perl module must return a true value
return 1;
####################################################################


