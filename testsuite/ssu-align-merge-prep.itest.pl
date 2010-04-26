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
if(($dir eq ".") || ($dir eq "./")) { die "ERROR, the output temporary directory cannot be \."; }
if($dir eq "data") { die "ERROR, the output temporary directory cannot be \"data\""; }

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

$fafile       = $datadir . "/v6-4.fa";
$fafile_full  = $datadir . "/seed-4.fa";
$fafile_15    = $datadir . "/seed-15.fa";
$trna_stkfile = $datadir . "/trna-5.stk";
$trna_fafile  = $datadir . "/trna-5.fa";
@name_A       = ("archaea", "bacteria", "eukarya");
@arc_only_A   = ("archaea");
@bac_only_A   = ("bacteria");
@euk_only_A   = ("eukarya");
$key_out = "181";

if (! -e "$fafile")      { die "FAIL: didn't find required fasta file $fafile"; }
if (! -e "$fafile_full") { die "FAIL: didn't find required fasta file $fafile_full"; }
if (! -e "$fafile_15")   { die "FAIL: didn't find required fasta file $fafile_15"; }
$testctr = 1;

open(PFXFILE, ">$dir.pfx") || die "FAIL: couldn't open $dir.pfx for writing prefix file";
print PFXFILE << "EOF";
qsub -N ssu-align -o /dev/null -b y -j y -cwd -V \"
EOF
close PFXFILE;

open(SFXFILE, ">$dir.sfx") || die "FAIL: couldn't open $dir.sfx for writing prefix file";
print SFXFILE << "EOF";
\"
EOF
close SFXFILE;


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
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test -b 100, we should only have 1 hit, the euk
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -b 100";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+0/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test -l 100, we should only have 1 hit, one of the bacs
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -l 100";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test -i, (check for --ileaved in cmalign output
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -i";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-ileaved\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test -n bacteria, should get the 2 bacteria guys, that's it
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f -n bacteria";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
	if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output =~ /\s+archaea\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output =~ /\s+eukarya\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --dna (check for --dna in the cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --dna";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-dna\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --keep-int
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --keep-int";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	check_for_files($dir, $dir, $testctr, \@name_A, ".sfetch");
	if(! -e ("$dir/$dir.cmsearch"))  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --rfonly (check for --matchonly in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --rfonly";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-matchonly\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --no-align
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-align";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.archaea.ifile"))   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --no-search (requires -n or --aln-one)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-search -n eukarya";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
	if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.bacteria.stk"))    { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.eukarya.fa"))      { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.eukarya.hitlist")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+eukarya\s+4/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --toponly (look for --toponly in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --toponly";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\-\-toponly/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --forward (look for --forward in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --forward";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "4";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\-\-forward/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --global (look for -g in cmsearch tab output) and search $fafile_full,
# which has full length seqs, should hit 2 archys, 1 bac
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --global";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile_full, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+2/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.tab`;
	if($output !~ /command\:.+cmsearch.+\s+\-g\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --no-trunc (use $fafile_full)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-trunc";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile_full, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+2.+\s+1\.00/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+1.+\s+1\.00/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1.+\s+1\.00/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --aln-one archaea
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --aln-one archaea";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
	if(-e ("$dir/$dir.bacteria.cmalign")) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if(-e ("$dir/$dir.eukarya.stk"))      { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1\s+/)   { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+alignment\s+1\s+/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --no-prob (check for --no-prob in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --no-prob";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-no\-prob/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# Test --mxsize 256 (check for --mxsize 256 in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f --mxsize 256";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "2";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.archaea.cmalign`;
	if($output !~ /command\:.+cmalign.+\-\-mxsize\s+256\s+/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

############################
# Test the special -m option
############################
# Note: the build parts of these tests are identical to those found in other test scripts: ssu-draw.itest.pl, ssu-mask.itest.pl
if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new trna.cm 
    $trna_cmfile = "trna-5.cm";
    @trna_only_A = ("trna-5");
    run_build($ssubuild, $trna_stkfile, "-f --rf -n $trna_only_A[0] -o $trna_cmfile", $testctr);
    check_for_files           (".", "", $testctr, \@trna_only_A, ".cm");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.log");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.sum");
    remove_files(".", "trna-5.ssu-build");

    # now, run ssu-align with new $trna_cmfile
    $align_opts = "-f -m $trna_cmfile";
    $merge_opts = "";
    $prep_opts  = "";
    $prep_nprocs = "3";
    for($i = 0; $i < $niter; $i++) { 
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $trna_fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@trna_only_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@trna_only_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@trna_only_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@trna_only_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@trna_only_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+trna\-5\s+4/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

##############################################################
# Done the 3 testing iterations of ssu-align specific options,
# now testing ssu-prep specific options. 
##############################################################
# test ssu-prep -x
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f"; 
    $merge_opts = "";
    $prep_opts  = "-x";
    $prep_nprocs = "2";
    # NOTE: we can't robustly test iteration 3 for ssu-prep -x, b/c it implies --no-merge, 
    # and thus, ssu-merge is then called immediately after the foo.ssu-align.sh call, and
    # the 'ssu-align &' calls from foo.ssu-align.sh will probably not be finished yet.
    # We only test iteration 2 ($i=1, below)
    $i = 1; 
    run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
				      $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
				      $ssualign, $ssumerge, $ssuprep, 
				      $fafile, $dir, $prep_nprocs, $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir.ssu-align.sh`;
    if($output !~ /will execute all $prep_nprocs jobs at once, in parallel/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\> \/dev\/null \&/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
}
$testctr++;

# test ssu-prep -q
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f"; 
    $merge_opts = "";
    $prep_opts  = "-q";
    $prep_nprocs = "2";
    for($i = 1; $i < $niter; $i++) { # do 2 of 3 iterations: ssu-prep, auto-merge; ssu-prep, manual merge;
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-prep.sum`;
	if($output !~ /with goal of equalizing number of sequences per job/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# test ssu-prep -e
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f"; 
    $merge_opts = "";
    $prep_opts  = "-e";
    $prep_nprocs = "2";
    for($i = 1; $i < $niter; $i++) { # do 2 of 3 iterations: ssu-prep, auto-merge; ssu-prep, manual merge;
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir/$dir.ssu-prep.sum`;
	if($output !~ /with goal of equalizing number of sequences per job/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	exit 0;
    }
}
$testctr++;

# test ssu-prep --no-bash
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f"; 
    $merge_opts = "";
    $prep_opts  = "--no-bash";
    $prep_nprocs = "4";
    for($i = 1; $i < $niter; $i++) { # do 2 of 3 iterations: ssu-prep, auto-merge; ssu-prep, manual merge;
	run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
					  $do_ssu_mergeA[$i], $do_ssu_prepA[$i],					  $ssualign, $ssumerge, $ssuprep, 
					  $fafile, $dir, $prep_nprocs, $testctr);
	check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
	check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
	check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
	check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
	check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
	$output = `cat $dir.ssu-align.sh`;
	if($output !~ /^\#\s+Shell script created/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	$output = `cat $dir/$dir.ssu-align.sum`;
	if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
	if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    }
}
$testctr++;

# test ssu-prep --keep-merge
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = "-f"; 
    $merge_opts = "";
    $prep_opts  = "--keep-merge";
    $prep_nprocs = "2";
    # NOTE: --keep-merge is incompatible with --no-merge, so we can't do iteration 3,
    # instead we only do iteration 2 ($i = 1 below)
    $i = 1; 
    run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
				      $do_ssu_mergeA[$i], $do_ssu_prepA[$i],
				      $ssualign, $ssumerge, $ssuprep, 
				      $fafile, $dir, $prep_nprocs, $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    # careful, v6-4.fa has 4 seqs, we've put the first 2 (a euk and a arc) into $dir/$dir.1
    #                                             last 2 (both bacs)       into $dir/$dir.2
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".cmalign");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".cmalign");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".cmalign");

    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
}
$testctr++;

# Test ssu-prep options that specify the prefix and suffix for the commands, don't
# actually run the commands though, just check that the $dir.ssu-align.sh files
# put the proper suffix and prefix before the ssu-align job commands.
# test ssu-prep -p
if(($testnum eq "") || ($testnum == $testctr)) {
    $prefix = "myprefix";
    $prep_opts  = "-f -p $prefix";
    $nprocs = "3";
    run_prep($ssuprep, $fafile, $dir, $nprocs, $prep_opts, $testctr);
    $output = `cat $dir.ssu-align.sh`;
    if($output !~ /\s+$prefix\s+ssu\-align/) { die "ERROR, problem with prep'ing (set $testctr)\n"; }
    if($output =~ /WARNING\:\s+None\s+of/)      { die "ERROR, problem with prep'ing (set $testctr)\n"; }
}
$testctr++;

# test ssu-prep -s
if(($testnum eq "") || ($testnum == $testctr)) {
    $suffix = "\\&";
    $prep_opts  = "-f -s $suffix";
    $nprocs = "3";
    run_prep($ssuprep, $fafile, $dir, $nprocs, $prep_opts, $testctr);
    $output = `cat $dir.ssu-align.sh`;
    if($output !~ /\&\s*$/) { die "ERROR, problem with prep'ing (set $testctr)\n"; }
    if($output =~ /WARNING\:\s+None\sof/) { die "ERROR, problem with prep'ing (set $testctr)\n"; }
}
$testctr++;

# test ssu-prep --fp and --fs simultaneously
if(($testnum eq "") || ($testnum == $testctr)) {
    $suffix = "\\&";
    $prep_opts  = "-f --fp $dir.pfx --fs $dir.sfx";
    $nprocs = "3";
    run_prep($ssuprep, $fafile, $dir, $nprocs, $prep_opts, $testctr);
    $output = `cat $dir.ssu-align.sh`;
    if($output !~ /\s+qsub \-N\s+ssu-align.+\".+\"/) { die "ERROR, problem with prep'ing (set $testctr)\n"; }
    if($output =~ /WARNING\:\s+None\sof/) { die "ERROR, problem with prep'ing (set $testctr)\n"; }
}
$testctr++;

###################################################
# Done testing ssu-prep-specific options. 
# Final step is to test ssu-merge specific options.
###################################################
# test ssu-merge --rfonly
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = ""; 
    $merge_opts = "--rfonly";
    $prep_opts  = "-f";
    $prep_nprocs = "3";
    # NOTE: we test only iteration 3, the:
    #   ssu-prep --no-merge $fafile foo; sh foo.ssu-align.sh; ssu-merge foo;
    $i = 2; 
    run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
				      $do_ssu_mergeA[$i], $do_ssu_prepA[$i], 
				      $ssualign, $ssumerge, $ssuprep, 
				      $fafile, $dir, $prep_nprocs, $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    # test that --rfonly was used, by looking for it in the ssu-merge command in $dir.ssu-merge.sum
    # and in the esl-alimerge command in $dir.ssu-merge.log
    $output = `cat $dir/$dir.ssu-merge.sum`;
    if($output !~ /command\:.+ssu\-merge\s+\-\-rfonly/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    $output = `cat $dir/$dir.ssu-merge.log`;
    if($output !~ /esl\-alimerge.+\-\-rfonly/)          { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
}
$testctr++;

# test ssu-merge --keep
if(($testnum eq "") || ($testnum == $testctr)) {
    $align_opts = ""; 
    $merge_opts = "--keep";
    $prep_opts  = "-f";
    $prep_nprocs = "2";
    # NOTE: we test only iteration 3, the:
    #   ssu-prep --no-merge $fafile foo; sh foo.ssu-align.sh; ssu-merge foo;
    $i = 2; 
    run_an_align_prep_merge_iteration($align_opts, $merge_opts, $prep_opts, 
				      $do_ssu_mergeA[$i], $do_ssu_prepA[$i], 
				      $ssualign, $ssumerge, $ssuprep, 
				      $fafile, $dir, $prep_nprocs, $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    # careful, v6-4.fa has 4 seqs, we've put the first 2 (a euk and a arc) into $dir/$dir.1
    #                                             last 2 (both bacs)       into $dir/$dir.2
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@arc_only_A, ".cmalign");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".1", $dir . ".1", $testctr, \@euk_only_A, ".cmalign");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".hitlist");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".fa");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".stk");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".ifile");
    check_for_files($dir . "/" . $dir . ".2", $dir . ".2", $testctr, \@bac_only_A, ".cmalign");

    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning (set $testctr, iteration: $iter_strA[$i])\n"; }
}
$testctr++;

# Test ssu-merge --list and other ssu-merge options that require --list,
# 
# test ssu-merge --list, --list -i and --list --dna
# We do one set of prep and align, then 3 rounds of merging:
open(ARCLIST, ">$dir.arclist") || die "FAIL: couldn't open $dir.arclist for writing list file";
print ARCLIST << "EOF";
$dir/$dir\.1/$dir\.1.archaea.stk
$dir/$dir\.2/$dir\.2.archaea.stk
EOF
close ARCLIST;

open(BACLIST, ">$dir.baclist") || die "FAIL: couldn't open $dir.baclist for writing list file";
print BACLIST << "EOF";
$dir/$dir\.3/$dir\.3.bacteria.stk
$dir/$dir\.4/$dir\.4.bacteria.stk
EOF
close BACLIST;

open(EUKLIST, ">$dir.euklist") || die "FAIL: couldn't open $dir.euklist for writing list file";
print EUKLIST << "EOF";
$dir/$dir\.5/$dir\.5.eukarya.stk
$dir/$dir\.6/$dir\.6.eukarya.stk
$dir/$dir\.7/$dir\.7.eukarya.stk
EOF
close EUKLIST;

if(($testnum eq "") || ($testnum == $testctr)) {

    $prep_opts  = "-f --no-merge";
    $prep_nprocs = "7";
    run_prep($ssuprep, $fafile_15, $dir, $prep_nprocs, $prep_opts, $testctr);
    run_align_post_prep($dir, $testctr);

    # types of alignments in each dir, following the prep, align steps:
    #        arc  bac  euk
    # foo.1  yes   no   no
    # foo.2  yes   no   no
    # foo.3   no  yes   no
    # foo.4   no  yes   no
    # foo.5   no   no  yes
    # foo.6   no   no  yes
    # foo.7   no   no  yes

    # first, run --list with no other options (except -f)
    $merge_opts = "-f";
    run_merge_in_list_mode($ssumerge, $dir . ".arclist", $dir . ".arc.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".arc.stk")) { die "FAIL: set $testctr failed to create file $dir.arc.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".baclist", $dir . ".bac.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".bac.stk")) { die "FAIL: set $testctr failed to create file $dir.bac.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".euklist", $dir . ".euk.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".euk.stk")) { die "FAIL: set $testctr failed to create file $dir.euk.stk"; }
    $output = `cat $dir.arc.ssu-merge.log`;
    if($output !~ /\-\-outformat\s+pfam/)  { die "ERROR, problem with merging (set $testctr)\n"; }

    $merge_opts = "-f -i";
    run_merge_in_list_mode($ssumerge, $dir . ".arclist", $dir . ".arc.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".arc.stk")) { die "FAIL: set $testctr failed to create file $dir.arc.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".baclist", $dir . ".bac.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".bac.stk")) { die "FAIL: set $testctr failed to create file $dir.bac.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".euklist", $dir . ".euk.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".euk.stk")) { die "FAIL: set $testctr failed to create file $dir.euk.stk"; }
    $output = `cat $dir.arc.ssu-merge.log`;
    if($output !~ /\-\-outformat\s+stockholm/)  { die "ERROR, problem with merging (set $testctr)\n"; }

    $merge_opts = "-f --dna";
    run_merge_in_list_mode($ssumerge, $dir . ".arclist", $dir . ".arc.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".arc.stk")) { die "FAIL: set $testctr failed to create file $dir.arc.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".baclist", $dir . ".bac.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".bac.stk")) { die "FAIL: set $testctr failed to create file $dir.bac.stk"; }
    run_merge_in_list_mode($ssumerge, $dir . ".euklist", $dir . ".euk.stk", $merge_opts, $testctr);
    if(! -e ($dir . ".euk.stk")) { die "FAIL: set $testctr failed to create file $dir.euk.stk"; }
    $output = `cat $dir.arc.ssu-merge.log`;
    if($output !~ /\-\-outformat\s+pfam/)  { die "ERROR, problem with merging (set $testctr)\n"; }
    if($output !~ /\-\-dna\s+/)  { die "ERROR, problem with merging (set $testctr)\n"; }

    unlink $dir . ".arc.stk";
    unlink $dir . ".arc.ssu-merge.sum";
    unlink $dir . ".arc.ssu-merge.log";
    unlink $dir . ".bac.stk";
    unlink $dir . ".bac.ssu-merge.sum";
    unlink $dir . ".bac.ssu-merge.log";
    unlink $dir . ".euk.stk";
    unlink $dir . ".euk.ssu-merge.sum";
    unlink $dir . ".euk.ssu-merge.log";
}
$testctr++;

# Clean up
unlink $dir . ".arclist";
unlink $dir . ".baclist";
unlink $dir . ".euklist";

unlink $dir . ".pfx";
unlink $dir . ".sfx";
if(-e "$dir.ssu-align.sh") { printf("$dir.ssu-align.sh exists"); }

# run ssu-prep one final time, to clear out $dir, so it'll be easier to remove:
system("$ssuprep -f $fafile $dir 2 > /dev/null");
if(-d $dir) { 
    foreach $file (glob("$dir/*")) { 
	unlink $file;
    }
    rmdir $dir;
}
if(-e "$dir.ssu-align.sh") { unlink $dir . ".ssu-align.sh"; }

printf("All commands completed successfully.\n");
exit 0;

sub run_an_align_prep_merge_iteration
{
    if(scalar(@_) != 12) { die "TEST SCRIPT ERROR: run_an_align_prep_merge_iteration " . scalar(@_) . " != 10 arguments."; }
    my ($align_opts, $merge_opts, $prep_opts, $do_merge, $do_prep, $ssualign, $ssumerge, $ssuprep, $fafile, $dir, $nprocs, $testctr) = @_;
    if($do_prep) { 
	$prep_opts .= " " . $align_opts;
	if($do_merge) { $prep_opts .= " --no-merge"; }
	run_prep($ssuprep, $fafile, $dir, $nprocs, $prep_opts, $testctr);
	run_align_post_prep($dir, $testctr);
    }
    else { # no prep, only use ssu-align
	run_align($ssualign, $fafile, $dir, $align_opts, $testctr);
    }
    if($do_merge) { 
	run_merge($ssumerge, $dir, $merge_opts, $testctr);
    }
    return;
}

    
