#ifndef __LZXXPR_CONVERT_H__
#define __LZXXPR_CONVERT_H__
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifndef _WIN32
#include "wintypes.h"
#include "dllloader.h"
#endif
#include "compress_msgs.h"
#include "stringutils.h"

//#define lzxxprtrace(...) fprintf(stderr, __VA_ARGS__)
#define lzxxprtrace(...)

class lzxxpr_convert {

// prototypes of cecompr_nt.dll
typedef LPVOID (*FNCompressAlloc)(DWORD AllocSize);
typedef VOID (*FNCompressFree)(LPVOID Address);
typedef DWORD (*FNCompressOpen)( DWORD dwParam1, DWORD MaxOrigSize, FNCompressAlloc AllocFn, FNCompressFree FreeFn, DWORD dwUnknown);
typedef DWORD (*FNCompressConvert)( DWORD stream, LPVOID out, DWORD outlength, LPCVOID in, DWORD insize); 
typedef VOID (*FNCompressClose)( DWORD stream);

public:
    lzxxpr_convert()
    {
        loaddlls();
//      fprintf(stderr, "lzxxpr_convert loaded\n");
    }

    // (de)compresses   {data|insize} ->  {out|outlength}, returns resulting size
    DWORD DoCompressConvert(int dwType, BYTE*out, DWORD outlength, const BYTE *data, DWORD insize)
    {
        DWORD stream;
        DWORD res;
        BYTE *in;

        FNCompressOpen CompressOpen= NULL;
        FNCompressConvert CompressConvert= NULL;
        FNCompressClose CompressClose= NULL;

        switch(dwType) {
        case ITSCOMP_XPR_DECODE:
            CompressOpen= XPR_DecompressOpen;
            CompressConvert= XPR_DecompressDecode;
            CompressClose= XPR_DecompressClose;
            break;
        case ITSCOMP_XPR_ENCODE:
            CompressOpen= XPR_CompressOpen;
            CompressConvert= XPR_CompressEncode;
            CompressClose= XPR_CompressClose;
            break;
        case ITSCOMP_LZX_DECODE:
            CompressOpen= LZX_DecompressOpen;
            CompressConvert= LZX_DecompressDecode;
            CompressClose= LZX_DecompressClose;
            break;
        case ITSCOMP_LZX_ENCODE:
            CompressOpen= LZX_CompressOpen;
            CompressConvert= LZX_CompressEncode;
            CompressClose= LZX_CompressClose;
            break;
        default:
            fprintf(stderr,"lzxxprcv: unknown type: %d\n", dwType);
            return 0xFFFFFFFF;
        }
        if (CompressOpen==NULL || CompressConvert==NULL || CompressClose==NULL) {
            return 0xFFFFFFFF;
        }
        if (CompressOpen) {
            stream= CompressOpen(0x10000, 0x2000, &Compress_AllocFunc, &Compress_FreeFunc, 0);
            if (stream==0 || stream==0xFFFFFFFF) {
                return 0xFFFFFFFF;
            }
        }

        in= new BYTE[0x2000];
        memcpy(in, data, insize);

        lzxxprtrace("lzxxpr(%d):(%p, 0x%x, %p, 0x%x, 0, 1, 4096)\n", dwType, in, insize, out, outlength);
        lzxxprtrace("lzxxpr(%d):in :%s\n", dwType, hexdump(in, insize).c_str());
        res= CompressConvert(stream, out, outlength, in, insize);
        if (res!=-1)
        lzxxprtrace("lzxxpr(%d):out:%s\n", dwType, hexdump(out, res).c_str());
//      fprintf(stderr, "->%08x\n", res);
//      if (res>0 && res<0x10000)
//          fprintf(stderr, "out: %s\n", hexdump(out, res).c_str());

        delete in;

        if (CompressClose)
            CompressClose(stream);
        return res;
    }

    void loaddlls()
    {
        LZX_CompressClose= NULL;
        LZX_CompressEncode= NULL;
        LZX_CompressOpen= NULL;
        LZX_DecompressClose= NULL;
        LZX_DecompressDecode= NULL;
        LZX_DecompressOpen= NULL;
        XPR_CompressClose= NULL;
        XPR_CompressEncode= NULL;
        XPR_CompressOpen= NULL;
        XPR_DecompressClose= NULL;
        XPR_DecompressDecode= NULL;
        XPR_DecompressOpen= NULL;
        hDllnt= LoadLibrary("cecompr_nt.dll");
        if (hDllnt!=NULL && hDllnt!=INVALID_HANDLE_VALUE) {
            LZX_CompressClose= (FNCompressClose)GetProcAddress(hDllnt, "LZX_CompressClose");
            LZX_CompressEncode= (FNCompressConvert)GetProcAddress(hDllnt, "LZX_CompressEncode");
            LZX_CompressOpen= (FNCompressOpen)GetProcAddress(hDllnt, "LZX_CompressOpen");
            LZX_DecompressClose= (FNCompressClose)GetProcAddress(hDllnt, "LZX_DecompressClose");
            LZX_DecompressDecode= (FNCompressConvert)GetProcAddress(hDllnt, "LZX_DecompressDecode");
            LZX_DecompressOpen= (FNCompressOpen)GetProcAddress(hDllnt, "LZX_DecompressOpen");
            XPR_CompressClose= (FNCompressClose)GetProcAddress(hDllnt, "XPR_CompressClose");
            XPR_CompressEncode= (FNCompressConvert)GetProcAddress(hDllnt, "XPR_CompressEncode");
            XPR_CompressOpen= (FNCompressOpen)GetProcAddress(hDllnt, "XPR_CompressOpen");
            XPR_DecompressClose= (FNCompressClose)GetProcAddress(hDllnt, "XPR_DecompressClose");
            XPR_DecompressDecode= (FNCompressConvert)GetProcAddress(hDllnt, "XPR_DecompressDecode");
            XPR_DecompressOpen= (FNCompressOpen)GetProcAddress(hDllnt, "XPR_DecompressOpen");
        }
        else {
            hDllnt= NULL;
            fprintf(stderr,"%08x: failed to load dllnt\n", GetLastError());
        }

    }
    HMODULE hDllnt;
    FNCompressClose LZX_CompressClose;
    FNCompressConvert LZX_CompressEncode;
    FNCompressOpen LZX_CompressOpen;
    FNCompressClose LZX_DecompressClose;
    FNCompressConvert LZX_DecompressDecode;
    FNCompressOpen LZX_DecompressOpen;
    FNCompressClose XPR_CompressClose;
    FNCompressConvert XPR_CompressEncode;
    FNCompressOpen XPR_CompressOpen;
    FNCompressClose XPR_DecompressClose;
    FNCompressConvert XPR_DecompressDecode;
    FNCompressOpen XPR_DecompressOpen;

static LPVOID Compress_AllocFunc(DWORD AllocSize)
{
    LPVOID p= malloc(AllocSize);

    //fprintf(stderr,"Compress_AllocFunc(%08lx) -> %08lx\n", AllocSize, p);

    return p;
}
static VOID Compress_FreeFunc(LPVOID Address)
{
    //fprintf(stderr,"Compress_FreeFunc(%08lx)\n", Address);
    free(Address);
}
};
#endif
