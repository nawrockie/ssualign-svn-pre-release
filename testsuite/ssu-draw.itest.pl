#! /usr/bin/perl
#
# Integrated test number 1 of the SSU-ALIGN scripts, focusing on ssu-draw.
#
# Usage:     ./ssu-draw.itest.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-draw.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-draw.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Mar 12 09:51:27 2010

$usage = "perl ssu-draw.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
$testnum = "";
if(scalar(@ARGV) == 3) { 
    ($scriptdir, $datadir, $dir) = @ARGV;
}
elsif(scalar(@ARGV) == 4) { 
    ($scriptdir, $datadir, $dir, $testnum) = @ARGV;
}
else { 
    printf("$usage\n");
    exit 0;
}
if($dir =~ m/draw/) { 
    die "ERROR, <tmpfile and tmpdir prefix> cannot contain 'draw'";
}

$scriptdir =~ s/\/$//; # remove trailing "/" 
$datadir   =~ s/\/$//; # remove trailing "/" 

$ssualign = $scriptdir . "/ssu-align";
$ssubuild = $scriptdir . "/ssu-build";
$ssudraw  = $scriptdir . "/ssu-draw";
$ssumask  = $scriptdir . "/ssu-draw";
$ssumerge = $scriptdir . "/ssu-merge";

if (! -e "$ssualign") { die "FAIL: didn't find ssu-mask script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }
if (! -x "$ssualign") { die "FAIL: ssu-mask script $ssualign is not executable"; }
if (! -x "$ssubuild") { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")  { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")  { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge") { die "FAIL: ssu-merge script $ssumerge is not executable"; }

$fafile       = $datadir . "/seed-15.fa";
$trna_stkfile = $datadir . "/trna-5.stk";
$trna_fafile  = $datadir . "/trna-5.fa";
$trna_psfile  = $datadir . "/trna-ssdraw.ps";
@name_A =     ("archaea", "bacteria", "eukarya");
@arc_only_A = ("archaea");
@bac_only_A = ("bacteria");
@euk_only_A = ("eukarya");
@ssudraw_only_A = ("ssu-draw");
$mask_key_in  = "181";
$mask_key_out = "1.8.1";

if (! -e "$fafile")       { die "FAIL: didn't find fasta file $fafile in data dir $datadir"; }
if (! -e "$trna_stkfile") { die "FAIL: didn't find file $trna_stkfile in data dir $datadir"; }
if (! -e "$trna_fafile")  { die "FAIL: didn't find file $trna_fafile in data dir $datadir"; }
if (! -e "$trna_psfile")  { die "FAIL: didn't find file $trna_psfile in data dir $datadir"; }
foreach $name (@name_A) {
    $maskfile = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
    if (! -e "$maskfile") { die "FAIL: didn't find mask file $maskfile in data dir $datadir"; }
}
$testctr = 1;

# Do ssu-align call, required for all tests:
#run_align($fafile, $dir, "-F", $testctr);
check_for_files($dir, $dir, $testctr, \@name_A, ".hits.list");
check_for_files($dir, $dir, $testctr, \@name_A, ".hits.fa");
check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");

#######################################
# Basic options (single letter options)
#######################################
# Test -h
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw("", "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-draw -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw                  ($dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;

# Test -a (on $dir.bacteria.stk in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test -a (on $dir.bacteria.stk in cwd/)
if(($testnum eq "") || ($testnum == $testctr)) {
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    run_draw                  ($dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "$dir.bacteria.stk");
}
$testctr++;

# Test --mask-key $mask_key_in
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input masks with the maskkey 
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir .     "/" . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_draw                  ($dir, "--mask-key $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@names_A) {
	$newmaskfile  = $dir . "/" . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # with -a, need to put mask files in cwd first
    foreach $name (@euk_only_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_draw                  ($dir . "/" . $dir . ".eukarya.stk", "--mask-key $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".pdf", ".ps");
    $output = `cat $dir.eukarya.ssu-draw.sum`;
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.eukarya.drawtab`;
    if($output !~ /infocontent\s+1\s+1.08\d+\s+3\s+3\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.6\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "eukarya.draw");
    remove_files              (".", "eukarya.ssu-draw");
    foreach $name (@euk_only_A) {
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # now test if mask files are in the cwd, not in $dir (without -a):
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_draw                  ($dir, "--mask-key $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@names_A) {
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }
}
$testctr++;

# Test -i
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a 
    run_draw                  ($dir, "-i", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_one_of_two_files($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_one_of_two_files($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".eukarya.stk", "-i -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".pdf", ".ps");
    $output = `cat $dir.eukarya.ssu-draw.sum`;
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.eukarya.drawtab`;
    if($output !~ /infocontent\s+1\s+1.08\d+\s+3\s+3\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.6\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "eukarya.draw");
    remove_files              (".", "eukarya.ssu-draw");
}
$testctr++;

###############################################
# Options for 1-page alignment summary diagrams
###############################################

# Test --prob
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--prob --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".prob.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".prob.pdf", ".prob.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.prob.p\w+/)     { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.prob.drawtab`;
    if($output !~ /avgpostprob\s+1\s+0.97\d+\s+2\s+6\s*avgpostprob/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--prob --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".prob.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".prob.pdf", ".prob.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.prob.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.prob.drawtab`;
    if($output !~ /avgpostprob\s+1\s+0.97\d+\s+2\s+6\s*avgpostprob/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.prob");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --ifreq
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--ifreq --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".ifreq.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".ifreq.pdf", ".ifreq.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.ifreq.p\w+/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.ifreq.drawtab`;
    if($output !~ /insertfreq\s+73\s+0.33\d+\s+3\s+5\s*insertfreq/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--ifreq --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ifreq.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".ifreq.pdf", ".ifreq.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.ifreq.p\w+/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.ifreq.drawtab`;
    if($output !~ /insertfreq\s+73\s+0.33\d+\s+3\s+5\s*insertfreq/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.ifreq");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --iavglen
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--iavglen --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".iavglen.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".iavglen.pdf", ".iavglen.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.iavglen.p\w+/)               { die "ERROR, iavglenlem with drawing"; }
    $output = `cat $dir/$dir.bacteria.iavglen.drawtab`;
    if($output !~ /insertavglen\s+73\s+1.00\d+\s+0.33\d+\s+3\s+1\s*insertavglen/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--iavglen --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".iavglen.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".iavglen.pdf", ".iavglen.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.iavglen.p\w+/)               { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.iavglen.drawtab`;
    if($output !~ /insertavglen\s+73\s+1.00\d+\s+0.33\d+\s+3\s+1\s*insertavglen/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.iavglen");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --dall
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--dall --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".dall.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".dall.pdf", ".dall.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dall.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.dall.drawtab`;
    if($output !~ /deleteall\s+99\s+0.6\d+\s+4\s*deleteall/)     { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--dall --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".dall.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".dall.pdf", ".dall.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dall.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.dall.drawtab`;
    if($output !~ /deleteall\s+99\s+0.6\d+\s+4\s*deleteall/)     { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.dall");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --dint
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--dint --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".dint.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".dint.pdf", ".dint.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dint.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.dint.drawtab`;
    if($output !~ /deleteint\s+99\s+0.2\d+\s+3\s+2\s*deleteint/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--dint --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".dint.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".dint.pdf", ".dint.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dint.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.dint.drawtab`;
    if($output !~ /deleteint\s+99\s+0.2\d+\s+3\s+2\s*deleteint/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.dint");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --span
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--span --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".span.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".span.pdf", ".span.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.span.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.span.drawtab`;
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--span --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".span.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".span.pdf", ".span.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.span.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.span.drawtab`;
    if($output !~ /span\s+1\s+0.4\d+\s+3\s*span/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.span");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --info
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--info --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".info.pdf", ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--info --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".info.pdf", ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --mutinfo
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--mutinfo --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mutinfo.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--mutinfo --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mutinfo.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+/)                                 { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.mutinfo");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --mutinfo with a mask
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input masks with the maskkey 
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir .     "/" . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_draw                  ($dir, "--mutinfo --mask-key $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mutinfo.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.mutinfo.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.mutinfo.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s+0\s+1\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@names_A) {
	$newmaskfile  = $dir . "/" . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # with -a, need to put mask files in cwd first
    foreach $name (@bac_only_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--mutinfo --mask-key $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mutinfo.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s+0\s+1\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.mutinfo");
    remove_files              (".", "bacteria.ssu-draw");
    foreach $name (@bac_only_A) {
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }
}
$testctr++;

# Test --indi-all
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($dir, "--indi-all --no-aln", $testctr);
    exit 0;
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mutinfo.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($dir . "/" . $dir . ".bacteria.stk", "--mutinfo --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mutinfo.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+/)                                 { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.mutinfo");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;


























exit 0;

# Test --pt
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($dir, "--pt 0.5", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1570\s+12/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--pt 0.5 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1570\s+12/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --pf and --pt
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--pt 0.5 --pf 0.75", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1571\s+11/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--pt 0.5 --pf 0.75 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1571\s+11/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --rfonly
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--rfonly", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1508\s+0/)  { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1582\s+0/) { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask\s+output\s+mask\s+1881\s+1881\s+0/)  { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($dir . "/" . $dir . ".archaea.stk", "--rfonly -a ", $testctr);
    check_for_files           (".", $dir, $testctr, \@arc_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@arc_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@arc_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.archaea.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1508\s+0/)  { die "ERROR, problem with masking"; }
    if($output =~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1582\s+0/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask\s+output\s+mask\s+1881\s+1881\s+0/)  { die "ERROR, problem with masking"; }
    remove_files              (".", "archaea.mask");
    remove_files              (".", "archaea.ssu-mask");
}
$testctr++;

# Test --gapthresh 0.4
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--gapthresh 0.4", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".pmask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".gmask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pmask.pdf", ".pmask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".gmask.pdf", ".gmask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".maskdiff.pdf", ".maskdiff.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1435\s+73/)         { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.pmask\s+output\s+mask\s+1582\s+1499\s+83/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.gmask\s+output\s+mask\s+1582\s+1525\s+57/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1457\s+125/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.maskdiff.p\w+\s+output\s+p\w+\s+1582\s+\-\s+\-/) { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1457\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--gapthresh 0.4 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".pmask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".gmask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", ".mask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pmask.pdf", ".pmask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".gmask.pdf", ".gmask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".maskdiff.pdf", ".maskdiff.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.pmask\s+output\s+mask\s+1582\s+1499\s+83/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.gmask\s+output\s+mask\s+1582\s+1525\s+57/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1457\s+125/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.maskdiff.p\w+\s+output\s+p\w+\s+1582\s+\-\s+\-/) { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1457\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.pmask");
    remove_files              (".", "bacteria.gmask");
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --gaponly --gapthresh 0.4
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--gaponly --gapthresh 0.4", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1467\s+41/)        { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1525\s+57/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1525\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--gaponly --gapthresh 0.4 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1467\s+41/)        { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1525\s+57/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1525\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

###############################
# Miscellaneous output options: 
###############################

# Test --afa
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--afa", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.afa");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.afa\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--afa -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.afa");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.afa\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --dna
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--dna", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--dna -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --key-out
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--key-out $mask_key_out", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask.pdf", ".$mask_key_out.mask.ps");
    $output = `cat $dir/$dir.$mask_key_out.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.$mask_key_out.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--key-out $mask_key_out -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask.pdf", ".$mask_key_out.mask.ps");
    $output = `cat $dir.eukarya.$mask_key_out.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.$mask_key_out.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya." . $mask_key_out . ".mask");
    remove_files              (".", "eukarya." . $mask_key_out . ".ssu-mask");
}
$testctr++;

#####################################################################
# Options for creating secondary structure diagrams displaying masks:
#####################################################################
# NOTE: --ps2pdf is not tested, I don't think any test of it would be portable...

# Test --ps-only
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a
    run_mask                  ($dir, "--ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --no-draw
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a 
    remove_files              ($dir, "mask");
    run_mask                  ($dir, "--no-draw", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output =~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--no-draw -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

###################################################################################
# Options for listing, converting, or removing sequences (no masking will be done):
###################################################################################
# Test --list
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a 
    run_mask                  ($dir, "--list", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".list");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.list\s+5/) { die "ERROR, problem with listing sequences"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.list\s+5/) { die "ERROR, problem with listing sequences"; }
    remove_files              ($dir, "mask");

    # with -a 
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /$dir.archaea.stk\s+$dir.archaea.list\s+5/) { die "ERROR, problem with listing sequences"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.list\s+5/) { die "ERROR, problem with listing sequences"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --stk2afa
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--stk2afa", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".afa");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              ($dir, "afa");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--stk2afa -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".afa");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /$dir.archaea.stk\s+$dir.archaea.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.afa");
    remove_files              (".", $dir . ".eukarya.ssu-mask");
}
$testctr++;

# Test --seq-k (only possible in combination with -a)
if(($testnum eq "") || ($testnum == $testctr)) {
    # first run --list to get a list
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $list_file = $dir . ".eukarya.list";
    $seqk_file = $dir . ".eukarya.seqk";
    open(LIST, $list_file) || die "TEST SCRIPT ERROR, unable to open file $list_file for reading.";
    $seq1 = <LIST>; chomp $seq1;
    $seq2 = <LIST>; chomp $seq2;
    $seq3 = <LIST>; chomp $seq3;
    $seq4 = <LIST>; chomp $seq4;
    $seq5 = <LIST>; chomp $seq5;
    close(LIST);
    open(SEQK, ">" . $seqk_file) || die "TEST SCRIPT ERROR, unable to open file $seqk_file for writing.";
    printf SEQK ("$seq1\n");
    printf SEQK ("$seq5\n");
    printf SEQK ("$seq4\n");
    close(SEQK);

    # now run ssu-mask --seq-k -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--seq-k $seqk_file -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".seqk.stk");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /archaea/)                   { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.seqk.stk\s+3/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.list");
    remove_files              (".", $dir . ".eukarya.seqk");
    remove_files              (".", $dir . ".eukarya.ssu-mask.sum");
}
$testctr++;

# Test --seq-r (only possible in combination with -a)
if(($testnum eq "") || ($testnum == $testctr)) {
    # first run --list to get a list
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $list_file = $dir . ".eukarya.list";
    $seqr_file = $dir . ".eukarya.seqr";
    open(LIST, $list_file) || die "TEST SCRIPT ERROR, unable to open file $list_file for reading.";
    $seq1 = <LIST>; chomp $seq1;
    $seq2 = <LIST>; chomp $seq2;
    $seq3 = <LIST>; chomp $seq3;
    $seq4 = <LIST>; chomp $seq4;
    $seq5 = <LIST>; chomp $seq5;
    close(LIST);
    open(SEQR, ">" . $seqr_file) || die "TEST SCRIPT ERROR, unable to open file $seqr_file for writing.";
    printf SEQR ("$seq1\n");
    printf SEQR ("$seq4\n");
    printf SEQR ("$seq5\n");
    close(SEQR);

    # now run ssu-mask --seq-r -a
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "--seq-r $seqr_file -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".seqr.stk");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /archaea/)                   { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.seqr.stk\s+2/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.list");
    remove_files              (".", $dir . ".eukarya.seqr");
    remove_files              (".", $dir . ".eukarya.ssu-mask.sum");
}
$testctr++;

####################################
# Test the special -m and -t options
####################################
if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new v4.cm with 3 v4 CMs
    run_build("-F -d --trunc 525-765  -n arc-v4 -o       v4.cm archaea", $testctr);
    check_for_files           (".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.stk");
    check_for_one_of_two_files(".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.ps", "-0p1-sb.525-765.pdf");
    remove_files              (".", "0p1-sb.525-765");

    run_build("-F -d --trunc 584-824  -n bac-v4 --append v4.cm bacteria", $testctr);
    check_for_files           (".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.stk");
    check_for_one_of_two_files(".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.ps", "-0p1-sb.584-824.pdf");
    remove_files              (".", "0p1-sb.584-824");

    run_build("-F -d --trunc 620-1082 -n euk-v4 --append v4.cm eukarya", $testctr);
    check_for_files           (".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.stk");
    check_for_one_of_two_files(".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.ps", "-0p1-sb.620-1082.pdf");
    remove_files              (".", "0p1-sb.620-1082");

    @v4_name_A = ("arc-v4", "bac-v4", "euk-v4");
    @v4_arc_only_A = ("arc-v4");

    # next, call ssu-align with new v4.cm
    run_align($fafile, $dir, "-F -m v4.cm", $testctr);
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".hits.list");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".hits.fa");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".cmalign");

    # mask alignments 
    # without -a 
    run_mask($dir, "-m v4.cm", $testctr);
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".mask");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".mask.stk");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bac-v4.mask\s+output\s+mask\s+241\s+237\s+4/) { die "ERROR, problem with masking";}
    remove_files(".", "archaea.mask");
    remove_files(".", "archaea.ssu-mask");

    # with -a 
    run_mask($dir . "/" . $dir . ".arc-v4.stk", "-a -m v4.cm", $testctr);
    check_for_files(".", $dir, $testctr, \@v4_arc_only_A, ".mask");
    check_for_files(".", $dir, $testctr, \@v4_arc_only_A, ".mask.stk");
    $output = `cat $dir.arc-v4.ssu-mask.sum`;
    if($output !~ /$dir.arc-v4.mask\s+output\s+mask\s+241\s+241\s+0/) { die "ERROR, problem with masking";}
    remove_files(".", "arc-v4.mask");
    remove_files(".", "arc-v4.ssu-mask");

    remove_files(".", "v4.cm");
}
$testctr++;

if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new trna.cm 
    $trna_cmfile = "trna-5.cm";
    @trna_only_A = "trna-5";
    run_build("-F --rf -n $trna_only_A[0] -o $trna_cmfile $trna_stkfile", $testctr);
    check_for_files           (".", "", $testctr, \@trna_only_A, ".cm");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.log");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.sum");
    remove_files(".", "trna-5.ssu-build");

    # next, call ssu-align with new $trna_cmfile
    run_align($trna_fafile, $dir, "-F -m $trna_cmfile", $testctr);
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".hits.list");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".hits.fa");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".cmalign");

    # mask alignments with -t $trna_psfile
    # without -a 
    run_mask($dir, "-t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@trna_only_A, ".mask.ps", ".mask.pdf");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}
    remove_files(".", "trna-5.mask");
    remove_files(".", "trna-5.ssu-mask");

    # with -a 
    run_mask($dir . "/" . $dir . ".trna-5.stk", "-a -t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask.stk");
    $output = `cat $dir.trna-5.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}
    remove_files(".", "trna-5.mask");
    remove_files(".", "trna-5.ssu-mask");
    remove_files(".", "trna-5.cm");
}
$testctr++;


printf("All commands completed successfully.\n");
exit 0;

#####################################################
# run_mask: Delete all '*mask*' files in $dir, then run 
#           ssu-mask and make sure it finishes.
#
# Arguments:
# $dir:            command-line argument for ssu-mask
# $extra_opts:     extra options for ssu-mask
# $testctr:            counter, for informative output when crashes
sub run_mask { 
    if(scalar(@_) != 3) { die "TEST SCRIPT ERROR: run_mask called with " . scalar(@_) . " != 3 arguments."; }
    my ($dir, $extra_opts, $testctr) = @_;
    if($extra_opts ne "") { $command = "$ssumask $extra_opts $dir > /dev/null"; }
    else                  { $command = "$ssumask $dir > /dev/null"; }
    printf("Running  mask command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask $testctr failed unexpectedly"; }

    return;
}
#####################################################
sub run_align { 
    my ($fafile, $dir, $extra_opts, $testctr) = @_;
    if($extra_opts ne "") { $command = "$ssualign $extra_opts $fafile $dir > /dev/null"; }
    else                  { $command = "$ssualign $fafile $dir > /dev/null"; }
    printf("Running align command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align $testctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_build { 
    my ($opts, $testctr) = @_;
    $command = "$ssubuild $opts > /dev/null"; 
    printf("Running build command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-build $testctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_draw {
    my ($dir, $extra_opts, $testctr) = @_;
    if($extra_opts ne "") { $command = "$ssudraw $extra_opts $dir > /dev/null"; }
    else                  { $command = "$ssudraw $dir > /dev/null"; }
    printf("Running  draw command for set %3d: $command\n", $testctr);
    system("$command");
    if ($? != 0) { die "FAIL: ssu-draw $testctr failed unexpectedly"; }
}
#####################################################
# check_for_files: Check if <dir>/<dir>.<name>.<suffix> exists
#                  for each <name> in $name_AR. Die if any do not exist.
sub check_for_files {
    my ($dir, $root, $testctr, $name_AR, $suffix) = @_;
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
    my ($dir, $root, $testctr, $name_AR, $suffix1, $suffix2) = @_;
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
    my ($dir, $str) = @_;
    if(! -d $dir) { return; }
    foreach $file (glob("$dir/*")) { 
	if($file =~ m/$str/) { unlink $file || die "TEST SCRIPT ERROR, unable to remove file $file in $dir"; }
    }
    return;
}
