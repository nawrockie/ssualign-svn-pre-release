#! /usr/bin/perl
#
# Integrated test of the SSU-ALIGN package that focuses on the ssu-align, ssu-merge and ssu-prep scripts.
#
# Usage:     ./ssu-align-merge-prep.itest.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-align-merge-prep.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-align-merge-prep.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Feb 26 11:29:22 2010

$usage = "perl ssu-align-merge-prep.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
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
$ssuprep  = $scriptdir . "/ssu-prep";
$ssu_itest_module = "ssu.itest.pm";

if (! -e "$ssualign")         { die "FAIL: didn't find ssu-align script $ssualign"; }
if (! -e "$ssubuild")         { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")          { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")          { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge")         { die "FAIL: didn't find ssu-merge script $ssumerge"; }
if (! -e "$ssuprep")          { die "FAIL: didn't find ssu-prep script $ssumerge"; }
if (! -x "$ssualign")         { die "FAIL: ssu-align script $ssualign is not executable"; }
if (! -x "$ssubuild")         { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")          { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")          { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge")         { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -x "$ssuprep")          { die "FAIL: ssu-merge script $ssuprep is not executable"; }
if (! -e "$ssu_itest_module") { die "FAIL: didn't find required Perl module $ssu_itest_module in current directory"; }

require $ssu_itest_module;

$fafile      = $datadir . "/v6-4.fa";
$fafile_full = $datadir . "/seed-4.fa";
@name_A =     ("archaea", "bacteria", "eukarya");
@arc_only_A = ("archaea");
@bac_only_A = ("bacteria");
@euk_only_A = ("eukarya");
$key_out = "181";

if (! -e "$fafile")      { die "FAIL: didn't find required fasta file $fafile"; }
if (! -e "$fafile_full") { die "FAIL: didn't find required fasta file $fafile"; }
$testctr = 1;

###############################################################################
# This test script is more complicated than the ssu-build.itest.pl, 
# ssu-draw.itest.pl and ssu-mask.itest.pl. It first tests all ssu-align
# options thrice, in 3 separate iterations:
# 
# Set up variables controlling our three-iteration test procedure:            
# Iteration 1: Run ssu-align only, ex:
#              > ssu-align foo.fa foo
# Iteration 2: Run ssu-prep, then execute the ssu-align script it generates,
#              which automatically merges the results:
#              > ssu-prep foo.fa foo <n>
#              > sh foo.ssu-align.sh 
# Iteration 3: Run ssu-prep with --no-merge, then execute the ssu-align script
#              it generates, then manually merge the results with ssu-merge:
#              > ssu-prep --no-merge foo.fa foo <n>
#              > sh foo.ssu-align.sh;
#              > ssu-merge foo
# 
# After all ssu-align options have been tested, ssu-prep-specific options
# are tested using default ssu-align (as opposed to testing all possible 
# combinations of ssu-prep-specific and ssu-align-specific
# options). 
#
# Finally, all ssu-merge-specific options are tested, again using
# only default ssu-align. 
####################################################################
$niter = 3;
@do_ssu_prepA  = ('0', '1', '1');
@do_ssu_mergeA = ('0', '0', '1');
@iter_strA = ("ssu-align only",
	      "ssu-prep; ssu-align (auto-merge)",
	      "ssu-prep; ssu-align --no-merge; ssu-merge");

###################################################
# First, the 3 iterations of all ssu-align options:
###################################################

#######################################
# Basic options (single letter options)
#######################################
# Test -h
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-align -h failed unexpectedly"; }
    run_merge($ssumerge, $dir, "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-merge -h failed unexpectedly"; }
    run_prep($ssuprep, $fafile, $dir, "4", "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-prep -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options) alignment
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test -b 100, we should only have 1 hit, the euk
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -b 100";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+0/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test -l 100, we should only have 1 hit, one of the bacs
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -l 100";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test -i, (check for --ileaved in cmalign output
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -i";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-ileaved\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test -n bacteria, should get the 2 bacteria guys, that's it
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -n bacteria";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output =~ /\s+archaea\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output =~ /\s+eukarya\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --dna (check for --dna in the cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --dna";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-dna\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --keep-int
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --keep-int";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	if(! -e ("$dir/$dir.cmsearch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --rfonly (check for --matchonly in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --rfonly";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-matchonly\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --no-align
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-align";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.archaea.ifile"))   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --no-search (requires -n or --aln-one)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-search -n eukarya";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
	if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.bacteria.stk"))    { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.eukarya.fa"))      { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.eukarya.hitlist")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+eukarya\s+4/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --toponly (look for --toponly in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --toponly";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\-\-toponly/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --forward (look for --forward in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --forward";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\-\-forward/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --global (look for -g in cmsearch tab output) and search $fafile_full,
# which has full length seqs, should hit 2 archys, 1 bac
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --global";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile_full, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+2/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\s+\-g\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --no-trunc (use $fafile_full)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-trunc";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile_full, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+2.+\s+1\.00/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+1.+\s+1\.00/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1.+\s+1\.00/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --aln-one archaea
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --aln-one archaea";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
	if(-e ("$dir/$dir.bacteria.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if(-e ("$dir/$dir.eukarya.stk"))      { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+alignment\s+1\s+/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --no-prob (check for --no-prob in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-prob";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-no\-prob/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

# Test --mxsize 256 (check for --mxsize 256 in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --mxsize 256";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-mxsize\s+256\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n" }
    }
}
$testctr++;

printf("All commands completed successfully.\n");
exit 0;

sub run_an_align_prep_merge_iteration
{
    if(scalar(@_) != 10) { die "TEST SCRIPT ERROR: run_an_align_prep_merge_iteration " . scalar(@_) . " != 10 arguments."; }
    my ($align_opts, $do_merge, $do_prep, $ssualign, $ssumerge, $ssuprep, $fafile, $dir, $nprocs, $testctr) = @_;
    my $prep_opts = $align_opts;
    if($do_prep) { 
	$prep_opts = $align_opts;
	if($do_merge) { $prep_opts .= " --no-merge"; }
	run_prep($ssuprep, $fafile, $dir, $nprocs, $prep_opts, $testctr);
	run_align_post_prep($dir, $testctr);
    }
    else { # no prep, only use ssu-align
	run_align($ssualign, $fafile, $dir, $align_opts, $testctr);
    }
    if($do_merge) { 
	run_merge($ssumerge, $dir, "", $testctr);
    }
    return;
}

    
