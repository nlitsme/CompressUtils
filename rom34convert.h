#ifndef __ROM34CONVERT_H__
#define __ROM34CONVERT_H__
#include <stdio.h>
#ifndef _WIN32
#include "wintypes.h"
#include "dllloader.h"
#endif
#include "compress_ipc.h"

class rom34convert {

    char*hexdump(const unsigned char*p, size_t n)
    {
        static char buf[65536];
        char *pbuf= buf;

        while (n--)
            pbuf += sprintf(pbuf, " %02x", *p++);

        return buf;
    }

// prototypes of cecompressv3.dll and cecompressv4.dll
typedef DWORD (*CECOMPRESS)(const unsigned char *lpbSrc, DWORD cbSrc, LPBYTE lpbDest, DWORD cbDest, WORD wStep, DWORD dwPagesize);
typedef DWORD (*CEDECOMPRESS)(const unsigned char *lpbSrc, DWORD cbSrc, LPBYTE  lpbDest, DWORD cbDest, DWORD dwSkip, WORD wStep, DWORD dwPagesize);

    HMODULE hDll3;
    CECOMPRESS compress3;
    CEDECOMPRESS decompress3;
    CEDECOMPRESS decompressRom3;

    HMODULE hDll4;
    CECOMPRESS compress4;
    CEDECOMPRESS decompress4;

public:
    rom34convert()
    {
        loaddlls();
    }

    void loaddlls()
    {
        compress4= NULL;
        decompress4= NULL;
        hDll4= LoadLibrary("CECompressv4.dll");
        if (hDll4!=NULL && hDll4!=INVALID_HANDLE_VALUE) {
            compress4= (CECOMPRESS)GetProcAddress(hDll4, "CECompress");
            decompress4= (CEDECOMPRESS)GetProcAddress(hDll4, "CEDecompress");
        }
        else {
            hDll4= NULL;
            fprintf(stderr,"%08x: failed to load dll4\n", GetLastError());
        }

        compress3= NULL;
        decompress3= NULL;
        decompressRom3= NULL;
        hDll3= LoadLibrary("CECompressv3.dll");
        if (hDll3!=NULL && hDll3!=INVALID_HANDLE_VALUE) {
            compress3= (CECOMPRESS)GetProcAddress(hDll3, "CECompress");
            decompress3= (CEDECOMPRESS)GetProcAddress(hDll3, "CEDecompress");
            decompressRom3= (CEDECOMPRESS)GetProcAddress(hDll3, "CEDecompressROM");
        }
        else {
            hDll3= NULL;
            fprintf(stderr,"%08x: failed to load dll3\n", GetLastError());
        }
//      fprintf(stderr,"loaded rom3+rom4: %p %p\n", hDll3, hDll4);
    }
    // (de)compresses   {data|insize} ->  {out|outlength}, returns resulting size
    DWORD DoCompressConvert(int dwType, BYTE*out, DWORD outlength, const BYTE *in, DWORD insize)
    {
        DWORD res;
//      fprintf(stderr, "%d->\nin: %s\n", dwType, hexdump(in, insize));
        switch(dwType) {
        case ITSCOMP_ROM3_DECODE:
            res= decompress3(in, insize, out, outlength, 0, 1, 4096);
            break;

        case ITSCOMP_ROM3_ENCODE:
            res= compress3(in, insize, out, outlength, 1, 4096);
            break;

        case ITSCOMP_ROM4_DECODE:
            res= decompress4(in, insize, out, outlength, 0, 1, 4096);
            break;

        case ITSCOMP_ROM4_ENCODE:
            res= compress4(in, insize, out, outlength, 1, 4096);
            break;

        default:
            fprintf(stderr,"rom34cv: unknown type: %d\n", dwType);
            return 0xFFFFFFFF;
        }
//      fprintf(stderr, "->%08x\n", res);
//      if (res>0 && res<0x10000)
//          fprintf(stderr, "out: %s\n", hexdump(out, res));
        return res;
    }
};
#endif
