#!perl -w
# vim: ft=perl
# (C) 2005 XDA Developers  itsme@xs4all.nl
use strict;

# NOTE: the commented out tests were there for experimenting, they are expected to fail
#
my $loaded;

my $t= 1;

BEGIN { $|=1; print "1..27\n"; }
END { print "not ok $t\n" unless $loaded; }
use XdaDevelopers::CompressUtils;
$loaded = 1;
print "ok $t\n";
$t++;

print "\n ... with 4 data ... \n";

# test example v4 decompression
my $compressed4= pack("H*", "f10000ba000010000000f1000000a4000000f10000005b80808d0010120f00000000230300400f434042447fa2be18b405aa2c93398451e5dae6b2756f12e5ef008400000400008846002008102e1de1c05810737dc25447fb3ba1f800000000000090010319cfccd721dfef10bf9f53ee829013b718099b96bc25250e8c6d11a0d8776e79d2660cde2ed289c99dda44bf14316eeadfeedeb0ece0e26cbc43e6cf2f5c2f10897a26cdbc2708bd4e7d42e13d8a9e2afcf26f00e0");
my $uncompressed4= pack("H*", "3c7374696e6765722d636f6e74726f6c70616e656c2d646f633e0d0a093c63706c2d7469746c65207265733d223330303430222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f7363686564756c652e63706c2e786d6c22207265733d223330303337222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f70632e63706c2e786d6c22207265733d223330303336222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f7365727665722e63706c2e786d6c22207265733d223330303538222f3e0d0a3c2f7374696e6765722d636f6e74726f6c70616e656c2d646f633e0d0a");

#testdecompress("rom3uncompress",  $compressed4, $uncompressed4, 1);
testdecompress("rom4uncompress",  $compressed4, $uncompressed4, 1);
#testdecompress("romuncompress_v3",  $compressed4, $uncompressed4);
testdecompress("romuncompress_v4",  $compressed4, $uncompressed4, 1);
#testdecompress("romuncompress_v5",  $compressed4, $uncompressed4);
testdecompress("rom3uncompressRom", $compressed4, $uncompressed4, 1);
#testdecompress("DoCeCompressDecode",$compressed4, $uncompressed4);

print "\n ... with 5 data ... \n";

my $compressed5= pack("H*", "0086a20a424d86000300461800281800101c00010002c30003b8000f0000aea10007006180808000c0c0c000ffff010008ffff00aa07002aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82a3b007900b900f900070001");
my $uncompressed5= pack("H*", "424d860000000000000046000000280000001000000010000000010002000000000000030000280f0000ae10000000000000000000000000000080808000c0c0c000ffffff00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82aaaaaa00aaaaa8282aaaa0aa0aaaa2aa8aaaaaaaaaaaaaaaaaaaaaaaaaa");

#testdecompress("rom3uncompress",  $compressed5, $uncompressed5, 1);
#testdecompress("rom4uncompress",  $compressed5, $uncompressed5, 1);
#testdecompress("romuncompress_v3",  $compressed5, $uncompressed5);
#testdecompress("romuncompress_v4",  $compressed5, $uncompressed5);
#testdecompress("romuncompress_v5",  $compressed5, $uncompressed5);
#testdecompress("rom3uncompressRom", $compressed5, $uncompressed5);
testdecompress("DoCeCompressDecode",$compressed5, $uncompressed5);


testpair(qw(romuncompress_v3 romcompress_v3), $uncompressed4, 1);
testpair(qw(rom3uncompress rom3compress), $uncompressed4, 1);
testpair(qw(rom4uncompress rom4compress), $uncompressed4, 1);
testpair(qw(DoCeCompressDecode DoCeCompressEncode), $uncompressed4, 0);

# this function apparently works differently, it crashes.
#testpair(qw(DoXpressDecode DoXpressEncode));

sub testdecompress {
    my ($decompress, $compressed, $uncompressed, $testsize)= @_;

    print "testing decompress: $decompress\n";

    # test if decompressing 'compressed' results in 'uncompressed'
    my $test1= eval("XdaDevelopers::CompressUtils::$decompress(\$compressed, length(\$uncompressed))");
    print "not " if (!defined $test1);
    print "ok $t - decompress defined\n";
    $t++;

    if (!defined $test1) {
        print "not ok $t\n"; 
        $t++;
    }
    else {
        print "not " if ($test1 ne $uncompressed);
        print "ok $t - decompress value\n";
        $t++;
    }

    return if (!$testsize);

    # test if too short len results in undef
    my $test2= eval("XdaDevelopers::CompressUtils::$decompress(\$compressed, length(\$uncompressed)-1)");
    print "not " if (defined $test2);
    print "ok $t - decompress size\n";
    $t++;
}
sub testpair {
    my ($decompress, $compress, $orig, $testtwice)= @_;

    print "testing pair: $decompress  $compress\n";

    # test if compress works
    my $test1= eval("XdaDevelopers::CompressUtils::$compress(\$orig)");
    print "not " if (!defined $test1);
    print "ok $t - pair compress\n";
    $t++;

    # test if twice compression results in undef ( data will not shrink more )
    if (!defined $test1) {
        print "not ok $t\n";
        $t++;
        print "not ok $t\n";
        $t++;
        print "not ok $t\n";
        $t++;
        return;
    }
    if ($testtwice) {
        my $test2= eval("XdaDevelopers::CompressUtils::$compress(\$test1)");
        print "not " if (defined $test2);
        print "ok $t - pair compress twice\n";
        $t++;
    }

    # test if v3 decompress works
    my $test3= eval("XdaDevelopers::CompressUtils::$decompress(\$test1, length(\$orig))");
    print "not " if (!defined $test3);
    print "ok $t - pair decompress defined\n";
    $t++;

    if (!defined $test3) {
        print "not ok $t\n";
        $t++;
    }
    else {
        print "not " if ($test3 ne $orig);
        print "ok $t - pair decompress value\n";
        $t++;
    }
}

