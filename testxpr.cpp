#include <stdint.h>
#include <stdio.h>
#include "lzxxpr_convert.h"
#include "FileFunctions.h"
#include "stringutils.h"
#include "debug.h"
typedef std::vector<uint8_t> ByteVector;
//uint8_t test[]= { 0xff,0xff,0x03,0x04,0x16,0x1f,0x00,0xea,0x00,0x07,0x00,0x1f,0x22,0x45,0x43,0x45,0x43,0x00,0xc5,0x20,0x80,0x18,0x00,0xaf,0x00,0x07,0x00,0x0f,0xff,0xa7,0x0f, };

// g++-mp-4.5 -m32 testxpr.cpp -I ../../itsutils/common dllloader.cpp ../../itsutils/common/stringutils.cpp -liconv
//
// echo 0086a20a424d86000300461800281800101c00010002c30003b8000f0000aea10007006180808000c0c0c000ffff010008ffff00aa07002aa8aaaa0aa0aaaa8282aaaaa00aaaaaa82a3b007900b900f900070001 | unhex | ./a.out 134
// g++-mp-4.5 -m32 -I ../../itsutils/common testxpr.cpp ../../itsutils/common/debug.cpp -D_NO_RAPI dllloader.cpp  ../../itsutils/common/stringutils.cpp  -liconv
int main(int argc,char**argv)
{
    DebugStdOut();
    lzxxpr_convert _lzxxpr;

    if (argc!=5 && argc!=6) {
        fprintf(stderr, "Usage: testxpr INFILE INoff INlen  OUTlen [outfile]\n");
        return 1;
    }
    size_t off= strtol(argv[2], 0, 0);
    size_t ilen= strtol(argv[3], 0, 0);
    size_t olen= strtol(argv[4], 0, 0);

    ByteVector uncomp(olen);
    ByteVector comp;
    if (!LoadFileData(argv[1], comp)) {
        perror(argv[1]);
        return 1;
    }
    if (ilen==-1)
        ilen= comp.size()-off;
    if (off> comp.size()) {
        fprintf(stderr, "off > file\n");
        return 1;
    }
    if (off+ilen> comp.size()) {
        fprintf(stderr, "off+ilen > file\n");
        return 1;
    }
    size_t n= _lzxxpr.DoCompressConvert(ITSCOMP_XPR_DECODE, &uncomp[0], uncomp.size(), &comp[off], ilen);
    if (n!=size_t(-1)) {
        fprintf(stderr, "got %d\n", n);
        if (argc==6) {
            FILE *f= fopen(argv[5], "a+b");
            if (f==NULL) {
                perror(argv[5]);
                return 1;
            }
            fwrite(&uncomp[0], n, 1, f);
            fclose(f);
        }
        else {
            bighexdump(0, uncomp);
        }
    }
    else {
        printf("err: %s\n", hexdump(&uncomp[0], 32).c_str());
    }

    return 0;
}

