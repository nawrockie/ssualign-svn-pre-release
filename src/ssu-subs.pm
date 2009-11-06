#!/usr/bin/perl
#
# ssu-subs.pm
# Eric Nawrocki
# EPN, Thu Nov  5 05:39:37 2009
#
# Perl module used by SSU-ALIGN v0.1 perl scripts. This module
# contains subroutines called by > 1 of the SSU-ALIGN perl scripts.
#
# List of subroutines in this file:
#
# PrintBanner():                prints SSU-ALIGN banner given a script description.
# PrintConclusion():            prints final lines of SSU-ALIGN script output
# PrintTiming():                prints run time to stdout and summary file.
# PrintStringToFile():          prints string to a file and optionally stdout.
# RunExecutable():              runs an executable with backticks, returns output.
# UnlinkFile():                 unlinks a file, and updates log file.
# DetermineNumSeqsFasta():      determine the number of sequences in a FASTA file.
# DetermineNumSeqsStockholm():  determine the number of sequences in a Stockholm aln file.
# ArgmaxArray():                determine the index of the max value scalar in an array
# MaxLengthScalarInArray():     determine the max length scalar in an array.
# TryPs2Pdf():                  attempt to run 'ps2pdf' to convert ps to pdf file.
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
#             run time timing.
#
# Arguments: 
#    $sum_file:         full path to summary file
#    $log_file2print:   name of log file
#    $sum_file2print:   name of summary file
#    $total_time:       total number of seconds, "" to not print timing
#    $out_dir:          output directory where output files were put,
#                       "" if it is current dir.
#
# Returns:    Nothing.
# 
####################################################################
sub PrintConclusion { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintConclusion() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($sum_file, $log_file2print, $sum_file2print, $total_time, $out_dir) = @_;

    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    PrintStringToFile($sum_file, 1, sprintf("# Commands executed by this script written to log file:  $log_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("# This output printed to screen written to summary file: $sum_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    if($out_dir ne "") { 
	PrintStringToFile($sum_file, 1, sprintf("# All output files created in directory \.\/%s\/\n", $out_dir));
	PrintStringToFile($sum_file, 1, sprintf("#\n"));
    }
    if($total_time ne "") { 
	PrintTiming("# CPU time: ", $total_time, $sum_file); 
	PrintStringToFile($sum_file, 1, sprintf("# \n"));
    }

    return;
}

#####################################################################
# Subroutine: PrintTiming()
# Incept:     EPN, Tue Jun 16 08:52:08 2009
# 
# Purpose:    Print a timing in hhhh:mm:ss format to 1 second precision.
# 
# Arguments:
# $prefix:       string to print before the hhhh:mm:ss time info.
# $inseconds:    number of seconds
# $sum_file:     file to print output file notices to
#
# Returns:    Nothing, if it returns, everything is valid.
# 
####################################################################
sub PrintTiming { 
    my $narg_expected = 3;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, print_timing() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($prefix, $inseconds, $sum_file) = @_;
    my ($i, $hours, $minutes, $seconds, $thours, $tminutes, $tseconds);

    $hours = int($inseconds / 3600);
    $inseconds -= ($hours * 3600);
    $minutes = int($inseconds / 60);
    $inseconds -= ($minutes * 60);
    $seconds = $inseconds;
    $thours   = $hours;
    $tminutes = $minutes;
    $tseconds = $seconds;

    if($hours < 10)   { $thours   = "0" . $thours; }
    if($minutes< 10)  { $tminutes = "0" . $tminutes; }
    if($seconds< 10)  { $tseconds = "0" . $tseconds; }

    PrintStringToFile($sum_file, 1, sprintf("%s %2s:%2s:%2s\n", $prefix, $thours, $tminutes, $tseconds));
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

    if ($command !~ m/2\>\&1$/) { $command .= " 2>&1"; }

    PrintStringToFile($log_file, 0, ("Executing:  \(" . $command . "\)\n"));
    $output = `$command`;

    PrintStringToFile($log_file, 0, ("Returned:   \(" . ($? >> 8) . "\)\n"));

    if(($? >> 8)!= 0) { 
	if($errmsg ne "") { 
	    PrintStringToFile($log_file, 0, ("Output:     \(" . $output . "\)\n\n"));
	    printf STDERR ("\n$errmsg\n");
	    PrintStringToFile($log_file, 0, ("\n$errmsg\n"));
	}
	if($print_output_upon_failure) { printf STDERR ("Command output: $output\n"); }
	if($die_if_fails) { exit(1); }
	$command_worked = 0;
    }
    else { 
	PrintStringToFile($log_file, 0, ("Output:     \(" . $output . "\)\n\n"));
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
    PrintStringToFile($log_file, 0, ("done.\n"));
    
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
    $command = "$seqstat $alifile 2>&1";
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


####################################################################
# the next line is critical, a perl module must return a true value
return 1;
####################################################################

