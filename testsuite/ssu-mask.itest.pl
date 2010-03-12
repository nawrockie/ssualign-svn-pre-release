#! /usr/bin/perl
#
# Integrated test number 1 of the SSU-ALIGN scripts, focusing on ssu-mask.
#
# Usage:     ./ssu-mask.itest.1.pl <directory with all 5 SSU-MASK scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-mask.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-mask.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Mar  5 08:33:29 2010

$usage = "perl ssu-mask.itest.pl\n\t<directory with all 5 SSU-MASK scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
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

$scriptdir =~ s/\/$//; # remove trailing "/" 
$datadir   =~ s/\/$//; # remove trailing "/" 

$ssualign = $scriptdir . "/ssu-align";
$ssubuild = $scriptdir . "/ssu-build";
$ssudraw  = $scriptdir . "/ssu-draw";
$ssumask  = $scriptdir . "/ssu-mask";
$ssumerge = $scriptdir . "/ssu-merge";

if (! -x "$ssualign") { die "FAIL: ssu-mask script $ssualign is not executable"; }
if (! -x "$ssubuild") { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")  { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")  { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge") { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -e "$ssualign") { die "FAIL: didn't find ssu-mask script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }

$fafile   = $datadir . "/seed-15.fa";
@name_A =     ("archaea", "bacteria", "eukarya");
@arc_only_A = ("archaea");
@bac_only_A = ("bacteria");
@euk_only_A = ("eukarya");
$mask_key_in  = "181";
$mask_key_out = "1.8.1";

if (! -e "$fafile")   { die "FAIL: didn't find fasta file $fafile in data dir $datadir"; }
foreach $name (@name_A) {
    $maskfile = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
    if (! -e "$maskfile") { die "FAIL: didn't find mask file $maskfile in data dir $datadir"; }
}
$testctr = 1;

# Do ssu-align call, required for all tests:
run_align($fafile, $dir, "-F", $testctr);

#######################################
# Basic options (single letter options)
#######################################
# Test -h
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask($dir, "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-mask -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # the only test where we do an ssu-draw call (ssu-draw is extensively tested by ssu-draw.itest.pl)
    run_draw                  ($dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;

# Test -a (on $dir.archaea.stk in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test -a (on $dir.archaea.stk in cwd/)
if(($testnum eq "") || ($testnum == $testctr)) {
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    run_mask                  ($dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test -d
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($dir, "-d", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask.stk+\s+output\s+aln+\s+1376\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1376\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.eukarya.mask.stk+\s+output\s+aln+\s+1343\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");
}
$testctr++;

# Test -k $mask_key_in
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input masks with the maskkey 
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir .     "/" . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_mask                  ($dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_mask                  ($dir . "/" . $dir . ".eukarya.stk", "-k $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukaryaa.ssu-mask");

    # now test if mask files they're in the cwd, not in $dir (without -a):
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_mask                  ($dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");
}
$testctr++;

# Test -i
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a 
    run_mask                  ($dir, "-i", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "-i -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

########################################
# Options controlling mask construction:
########################################

# Test --pf
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($dir, "--pf 0.75", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1543\s+39/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($dir . "/" . $dir . ".bacteria.stk", "--pf 0.75 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1543\s+39/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

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
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
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
    remove_files              (".", $dir . ".eukarya.ssu-mask.sum");
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
	$file = $dir . "/" . $root . "." . $name . $suffix;
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
	$file1 = $dir . "/" . $root . "." . $name . $suffix1;
	$file2 = $dir . "/" . $root . "." . $name . $suffix2;
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
