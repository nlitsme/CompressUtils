#ifndef __WIN32COMPRESS_SERVER_H__
#define __WIN32COMPRESS_SERVER_H__
#include "compress_ipc.h"
#include "lzxxpr_convert.h"
#include "rom34convert.h"

#if defined(USE_POPEN)
#include "popen_ipc.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc.h"
#elif defined(USE_SOCKET)
#include "socket_ipc.h"
#endif

class win32compress_server {
    lzxxpr_convert _lzxxpr;
    rom34convert  _rom34;

#if defined(USE_POPEN)
    popen_ipc_server _ipc;
#elif defined(USE_PSTREAM)
    pstream_ipc_server _ipc;
#elif defined(USE_SOCKET)
    socket_ipc_server _ipc;
#endif

public:
    win32compress_server()
    {
//      fprintf(stderr, "server: reqsize=%d, ressize=%d\n", (int)sizeof(compressrequest), (int)sizeof(compressresult));
    }
    ~win32compress_server()
    {
    }

    bool server()
    {
//      fprintf(stderr,"server: waiting for request\n");
        compressrequest  req;
        if (!_ipc.read(&req, sizeof(req)))
            return false;

//      fprintf(stderr,"server: got request %d: %d bytes\n", req.dwType, req.insize);

        compressresult result;
        memset(&result, 0, sizeof(result));

        switch(req.dwType)
        {
case ITSCOMP_XPR_DECODE:
case ITSCOMP_XPR_ENCODE:
case ITSCOMP_LZX_DECODE:
case ITSCOMP_LZX_ENCODE:
        result.resultLen= _lzxxpr.DoCompressConvert(req.dwType, result.out, req.outlength, req.data, req.insize);
        break;
case ITSCOMP_ROM3_DECODE:
case ITSCOMP_ROM3_ENCODE:
case ITSCOMP_ROM4_DECODE:
case ITSCOMP_ROM4_ENCODE:
        result.resultLen= _rom34.DoCompressConvert(req.dwType, result.out, req.outlength, req.data, req.insize);
        break;
        }

//      fprintf(stderr,"server: sending reply %d bytes\n", result.resultLen);
        if (!_ipc.write(&result, sizeof(result)))
            return false;
        return true;
    }
};
#endif
