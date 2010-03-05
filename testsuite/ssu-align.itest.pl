#! /usr/bin/perl
#
# Integrated test of the SSU-ALIGN package that focuses on the ssu-align script.
#
# Usage:     ./ssu-align.itest.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-align.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-align.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Feb 26 11:29:22 2010

$usage = "perl ssu-align.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
$testnum = "";
if(scalar(@ARGV) == 3) { 
    ($scriptdir, $datadir, $tmppfx) = @ARGV;
}
elsif(scalar(@ARGV) == 4) { 
    ($scriptdir, $datadir, $tmppfx, $testnum) = @ARGV;
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

if (! -x "$ssualign") { die "FAIL: ssu-align script $ssualign is not executable"; }
if (! -x "$ssubuild") { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")  { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")  { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge") { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -e "$ssualign") { die "FAIL: didn't find ssu-align script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }

$fafile = $datadir . "/seed-4.fa";
if (! -e "$fafile") { die "FAIL: didn't find required fasta file $fafile"; }

$testctr = 1;

# Test 1
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-align.sum`;
    if($output !~ /bacteria\s+1\s+0.25\d+\s+1533.\d+\s+0.99\d+\s+1533/) { 
	die "ERROR, problem with alignment"; 
    }
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 2
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F -m ../seeds/archaea-0p1.cm $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-align.sum`;
    if($output =~ /bacteria\s+1\s+0.25\d+\s+1533.\d+\s+0.99\d+\s+1533/) { 
	die "ERROR, problem with alignment"; 
    }
    if($output !~ /archaea\s+4\s+1.00\d+\s+997.\d+\s+0.82\d+\s+3990/)   {
	die "ERROR, problem with alignment"; 
    }
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;
    
# Test 3
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F -b 1400 $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-align.sum`;
    if($output !~ /archaea\s+1\s+0.25\d+\s+1486.\d+\s+0.8348\d+\s+1486/) { 
	die "ERROR, problem with alignment"; 
    }
    if($output !~ /eukarya\s+0\s+0.00\d+\s+\-\s+\-\s+0/) { 
	die "ERROR, problem with alignment"; 
    }
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 4
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F -l 700 $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 5
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F -i $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "-i", $testctr);
    run_draw($tmppfx, "-i", $testctr);
}
$testctr++;

# Test 6
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --dna $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 7
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --keep $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 8
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --rfonly $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 9
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --only eukarya $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 10
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --no-align $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    # don't mask or draw, we didn't create any alignments
}
$testctr++;

# Test 11
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --no-search --only bacteria $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 12
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --toponly $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 13
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --forward $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 14
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --global $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 15
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --no-trunc $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 16
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --aln-one bacteria $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 17
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --aln-one bacteria $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 18
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --no-prob $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 19
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssualign -F --mxsize 1024 $tmppfx.fa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align failed unexpectedly";}
    run_mask($tmppfx, "", $testctr);
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

printf("All commands completed successfully.\n");
exit 0;

#####################################################
sub run_mask { 
    ($pfx, $extra_opts, $ctr) = @_;
    $command = "$ssumask $extra_opts $pfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask $ctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_draw {
    ($pfx, $extra_opts, $ctr) = @_;
    $command = "$ssudraw $extra_opts $pfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-draw $ctr failed unexpectedly"; }
}
#####################################################
