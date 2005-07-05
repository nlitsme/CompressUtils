#!perl -w
# (C) 2005 XDA Developers  itsme@xs4all.nl
use strict;

my $loaded;

BEGIN { $|=1; print "1..6\n"; }
END { print "not ok 1\n" unless $loaded; }
use XdaDevelopers::CompressUtils;
$loaded = 1;
print "ok 1\n";

# test example v4 decompression
my $compressed4= pack("H*", "f10000ba000010000000f1000000a4000000f10000005b80808d0010120f00000000230300400f434042447fa2be18b405aa2c93398451e5dae6b2756f12e5ef008400000400008846002008102e1de1c05810737dc25447fb3ba1f800000000000090010319cfccd721dfef10bf9f53ee829013b718099b96bc25250e8c6d11a0d8776e79d2660cde2ed289c99dda44bf14316eeadfeedeb0ece0e26cbc43e6cf2f5c2f10897a26cdbc2708bd4e7d42e13d8a9e2afcf26f00e0");
my $uncompressed4= pack("H*", "3c7374696e6765722d636f6e74726f6c70616e656c2d646f633e0d0a093c63706c2d7469746c65207265733d223330303430222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f7363686564756c652e63706c2e786d6c22207265733d223330303337222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f70632e63706c2e786d6c22207265733d223330303336222f3e0d0a093c63706c2d6c696e6b20687265663d2273796e635f7365727665722e63706c2e786d6c22207265733d223330303538222f3e0d0a3c2f7374696e6765722d636f6e74726f6c70616e656c2d646f633e0d0a");

my $test2= XdaDevelopers::CompressUtils::romuncompress_v4($compressed4, length($uncompressed4));
print "not " if ($test2 ne $uncompressed4);
print "ok 2\n";

# test if too short len results in undef
my $test3= XdaDevelopers::CompressUtils::romuncompress_v4($compressed4, length($uncompressed4)-1);
print "not " if (defined $test3);
print "ok 3\n";

# test if v3 compress works
my $orig= "test" x 10;
my $test4= XdaDevelopers::CompressUtils::romcompress_v3($orig);
print "not " if (!defined $test4);
print "ok 4\n";

# test if twice compression results in undef ( data will not shrink more )
my $test5= XdaDevelopers::CompressUtils::romcompress_v3($test4);
print "not " if (defined $test5);
print "ok 5\n";

# test if v3 decompress works
my $test6= XdaDevelopers::CompressUtils::romuncompress_v3($test4, length($orig));
print "not " if ($test6 ne $orig);
print "ok 6\n";

# my $compressed5= pack("H*", "0086a20a424d86000300461800281800101c00010002c30003b8000f0000aea10007006180808000c0c0c000ffff010008ffff00aa07002aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82a3b007900b900f900070001");
# my $uncompressed5= pack("H*", "424d860000000000000046000000280000001000000010000000010002000000000000030000280f0000ae10000000000000000000000000000080808000c0c0c000ffffff00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82aaaaaa00aaaaa8282aaaa0aa0aaaa2aa8aaaaaaaaaaaaaaaaaaaaaaaaaa");
# my $test7= XdaDevelopers::CompressUtils::romuncompress_v5($compressed5, length($uncompressed5));
# print "not " if (!defined $test7 || $test7 ne $uncompressed5);
# print "ok 7\n";
# 
# # test if dll compress works
# my $test8= XdaDevelopers::CompressUtils::romcompress_dll($orig);
# print "not " if (!defined $test8);
# print "ok 8\n";
# 
# # test if twice compression results in undef ( data will not shrink more )
# my $test9= XdaDevelopers::CompressUtils::romcompress_dll($test8);
# print "not " if (defined $test9);
# print "ok 9\n";
# 
# # test if dll decompress works
# my $test10= XdaDevelopers::CompressUtils::romuncompress_dll($test8, length($orig));
# print "not " if ($test10 ne $orig);
# print "ok 10\n";
# 

