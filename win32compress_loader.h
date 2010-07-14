#ifndef __WIN32COMPRESS_LOADER_H__
#define __WIN32COMPRESS_LOADER_H__
#include "lzxxpr_convert.h"
#include "rom34convert.h"
class win32compress_loader {
    lzxxpr_convert _lzxxpr;
    rom34convert  _rom34;

public:
    win32compress_loader()
    {
//      fprintf(stderr, "win32compress_loader\n");
    }
    ~win32compress_loader()
    {
    }

    // only used from the xs file: constructors do not seem to be run
    // from .xs
    void loaddlls()
    {
        _lzxxpr.loaddlls();
        _rom34.loaddlls();
    }

    DWORD DoCompressConvert(int dwType, BYTE*out, DWORD outlength, const BYTE *data, DWORD insize)
    {
        switch(dwType)
        {
case ITSCOMP_XPR_DECODE:
case ITSCOMP_XPR_ENCODE:
case ITSCOMP_XPH_DECODE:
case ITSCOMP_XPH_ENCODE:
case ITSCOMP_LZX_DECODE:
case ITSCOMP_LZX_ENCODE:
        return _lzxxpr.DoCompressConvert(dwType, out, outlength, data, insize);
        break;
case ITSCOMP_ROM3_DECODE:
case ITSCOMP_ROM3_ENCODE:
case ITSCOMP_ROM4_DECODE:
case ITSCOMP_ROM4_ENCODE:
        return _rom34.DoCompressConvert(dwType, out, outlength, data, insize);
        break;
        }

        return 0xFFFFFFFF;
    }
};
#endif

