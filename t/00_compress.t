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
#NOLIBS - testdecompress("romuncompress_v4",  $compressed4, $uncompressed4, 1);
#testdecompress("romuncompress_v5",  $compressed4, $uncompressed4);
testdecompress("rom3uncompressRom", $compressed4, $uncompressed4, 1);
#testdecompress("DoCeCompressDecode",$compressed4, $uncompressed4);

print "\n ... with 5 XPR data ... \n";

my $compressed5_xpr= pack("H*", "0086a20a424d86000300461800281800101c00010002c30003b8000f0000aea10007006180808000c0c0c000ffff010008ffff00aa07002aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82a3b007900b900f900070001");
my $uncompressed5_xpr= pack("H*", "424d860000000000000046000000280000001000000010000000010002000000000000030000280f0000ae10000000000000000000000000000080808000c0c0c000ffffff00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82aaaaaa00aaaaa8282aaaa0aa0aaaa2aa8aaaaaaaaaaaaaaaaaaaaaaaaaa");

#testdecompress("rom3uncompress",  $compressed5_xpr, $uncompressed5_xpr, 1);
#testdecompress("rom4uncompress",  $compressed5_xpr, $uncompressed5_xpr, 1);
#testdecompress("romuncompress_v3",  $compressed5_xpr, $uncompressed5_xpr);
#testdecompress("romuncompress_v4",  $compressed5_xpr, $uncompressed5_xpr);
#testdecompress("romuncompress_v5",  $compressed5_xpr, $uncompressed5_xpr);
#testdecompress("rom3uncompressRom", $compressed5_xpr, $uncompressed5_xpr);
#NOLIBS - testdecompress("DoCeCompressDecode",$compressed5_xpr, $uncompressed5_xpr);
testdecompress("XPR_DecompressDecode",$compressed5_xpr, $uncompressed5_xpr);

print "\n ... with 5 LZX data ... \n";

my $compressed5_lzx= pack("H*","a8000000e50000005b80808d0010510e00000000330300500e452754dc6b2ec802a1674a659ba437edabaaca70b708aaffa9ffff40700000000000cd0d0030017121812726329885cc964e4915aaff3ffeff800000000000000001104200ff42ffff22fd4129593663b748a75aa83093ef5a2f386c5fc730e6b2c2b784cc5b4737b11c19fa20fcbcec0a96fe28c0efa35af83b80076ba675ffa73ea7954b7f8164a204e6787cb945ef110893d06e0040");

my $uncompressed5_lzx= pack("H*","4d4d4920416c6c0d0a5452414345434c4153532046460d0a4d4d490d0a0d0a4d4d20416c6c0d0a5452414345434c4153532046460d0a4d4d0d0a0d0a474d4d20414c4c0d0a5452414345434c4153532046460d0a474d4d0d0a0d0a434320416c6c0d0a5452414345434c4153532046460d0a43430d0a0d0a534d5320416c6c0d0a5452414345434c4153532046460d0a534d530d0a0d0a5353204576656e740d0a5452414345434c4153532030320d0a53530d0a0d0a4c31205374642054726163650d0a434f4e464947204c315f504152414d533d3c302c3132373e0d0a4353540d0a0d0a");

my $compressed5_lzx2= pack("H*","58010000800200005b80808d002000280810008100002300005040006f5fde7b13b4caeaa261155ab84448500885d5a81245c08d17b9270a11b82870258d6a4b52b517842112e555a26a818ba12b914b402400000600a86804a0ef814da29200046a24238ac45291913c18898891a492195efd3b10fe00400000000000002166cff6679366df7cea30a3fdd43f5ee8453669084355a26514e3c2ad887a05c7e815598f0e4189975af781b70d839429b9b0f04254142c4bb1620ca1086e876472e6f206b4c5daa11cf49660bb0de4a8a18824380ec8c619d76bef840304e5a7bc915530e5038a1a7eca4dc27c885076fe6077021795a66f0a75495f397a39a9cc0b4ac9680bb334ac0e2548c1daed9e19714695e6505a3a1e4517ca7456d4ab1ec4a5bdcb748456ce09637fe5f12e51ffd930b0704af368da3db7a52952a6e342544451953e47a642587753b626f3be27f830bbdcfedf97bfd0b0fababa8bdca7"); # 
my $uncompressed5_lzx2= pack("H*", "d0010080240000805407008055070080c80100807e0500801002008011020080c4000080c50000803f0000802c0400807b0300801e01008001010080000100802a040080e0000080dd000080ab020080a10200804e0300800801008003010080020100801d0100805b0300806a03008060030080610300806403008005020080cd020080800300808f04008014040080a4000080a000008024020080b5000080a7000080a1000080a9000080a2000080a500008014020080c6000080a8000080a6000080990400802f0400801d02008019020080ef01008038000080890500800d03008007030080c8000080ca000080cb000080cc00008053070080cd0100805a030080c0020080c00000800f010080fb0000801702008056030080fd00008013000080190000809603008090030080d3030080c8030080cc030080d403008012020080d70300808006008097030080930300802502008014000080ce0400802b0200804200008029020080a30600804b000080df050080cf0100803d0000805e03008057000080ee01008002000080050000800400008003000080f101008046040080470400809d0200809f020080a5020080040200809c0200802100008023000080a0020080c701008016040080310400800000000086530000745300000000000000000000ac50bd0300000000000000000000000000000000000000000000000000000000ffffffff9b4fffff64b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
#testdecompress("rom3uncompress",  $compressed5_lzx, $uncompressed5_lzx, 1);
#testdecompress("rom4uncompress",  $compressed5_lzx, $uncompressed5_lzx, 1);
#testdecompress("romuncompress_v3",  $compressed5_lzx, $uncompressed5_lzx);
#testdecompress("romuncompress_v4",  $compressed5_lzx, $uncompressed5_lzx);
#testdecompress("romuncompress_v5",  $compressed5_lzx, $uncompressed5_lzx);
#testdecompress("rom3uncompressRom", $compressed5_lzx, $uncompressed5_lzx);
#testdecompress("DoCeCompressDecode",$compressed5_lzx, $uncompressed5_lzx);
testdecompress("LZX_DecompressDecode",$compressed5_lzx, $uncompressed5_lzx);
testdecompress("LZX_DecompressDecode",$compressed5_lzx2, $uncompressed5_lzx2);
print "\n ... testing function pairs ... \n";


#NOLIBS - testpair(qw(romuncompress_v3 romcompress_v3), $uncompressed4, 1);
testpair(qw(rom3uncompress rom3compress), $uncompressed4, 1);
testpair(qw(rom4uncompress rom4compress), $uncompressed4, 1);
#NOLIBS - testpair(qw(DoCeCompressDecode DoCeCompressEncode), $uncompressed4, 0);
testpair(qw(LZX_DecompressDecode LZX_CompressEncode), $uncompressed5_lzx, 0);
testpair(qw(XPR_DecompressDecode XPR_CompressEncode), $uncompressed5_xpr, 0);

# this function apparently works differently, it crashes.
#testpair(qw(DoXpressDecode DoXpressEncode));

# add 3 to total test count for each testdecompress call
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
# add 4 to total test count for each testpair call
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

