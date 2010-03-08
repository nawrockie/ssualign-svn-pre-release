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
# HERE HERE HERE
# make array of family names: "archaea", "bacteria", "eukarya",
# then set $masksuffix to ".1.mask", then use them all when testing
# key-in for example.
$maskfile = $datadir . "/archaea.1.mask";
if (! -e "$fafile")   { die "FAIL: didn't find fasta file $fafile in current directory"; }
if (! -e "$maskfile") { die "FAIL: didn't find fasta file $fafile in current directory"; }

$testctr = 1;

# Do ssu-align call, required for all tests:
run_align($fafile, $tmppfx, "-F", $testctr);

# Test 1
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssumask $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-mask.sum`;
    if($output !~ /foo.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 2
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssumask --afa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-mask.sum`;
    if($output !~ /foo.eukarya.mask.stk\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    if($output !~ /foo.eukarya.mask.afa\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 3
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssumask --only-afa $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-mask.sum`;
    if($output =~ /foo.eukarya.mask.stk\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    if($output !~ /foo.eukarya.mask.afa\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 4
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssumask --dna $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-mask.sum`;
    if($output !~ /foo.eukarya.mask.stk\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "", $testctr);
}
$testctr++;

# Test 5
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input mask with the key 
    $maskkey = "181";
    $newmaskfile = $tmppfx . "/archaea.$maskkey.mask";
    system("cp $maskfile $newmaskfile");
    $command = "$ssumask --mask-key $maskkey $tmppfx > /dev/null";
    if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.ssu-mask.sum`;
    if($output !~ /foo.eukarya.$maskkey.mask.stk\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "--key-in $maskkey", $testctr);
}
$testctr++;

# Test 6
if(($testnum eq "") || ($testnum == $testctr)) {
    $command = "$ssumask --key-out 181 $tmppfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-mask failed unexpectedly";}
    $output = `cat $tmppfx/$tmppfx.181.ssu-mask.sum`;
    if($output !~ /foo.eukarya.181.mask.stk\s+output\s+aln\s+1634/) { 
	die "ERROR, problem with masking"; 
    }
    run_draw($tmppfx, "--key-in 181", $testctr);
}
$testctr++;

printf("All commands completed successfully.\n");
exit 0;

#####################################################
sub run_align { 
    ($fafile, $pfx, $extra_opts, $ctr) = @_;
    $command = "$ssualign $extra_opts $fafile $pfx > /dev/null";
    printf("Running command: $command\n");
    system("$command");
    if ($? != 0) { die "FAIL: ssu-align $ctr failed unexpectedly"; }
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
