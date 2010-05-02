#ifndef __WIN32COMPRESS_SERVER_H__
#define __WIN32COMPRESS_SERVER_H__
#include "compress_msgs.h"
#include "lzxxpr_convert.h"
#include "rom34convert.h"

#if defined(USE_POPEN)
#include "popen_ipc_clt.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc_clt.h"
#elif defined(USE_SOCKET)
#include "socket_ipc_clt.h"
#elif defined(USE_PIPE)
#include "pipe_ipc_clt.h"
#endif
#if defined(USE_SOCKET)
#include "socket_ipc_svr.h"
#else
#include "stdio_ipc_svr.h"
#endif

//#define csvrlog(...) fprintf(stderr, __VA_ARGS__)
#define csvrlog(...)

class win32compress_server {
    lzxxpr_convert _lzxxpr;
    rom34convert  _rom34;

#if defined(USE_SOCKET)
    socket_ipc_server _ipc;
#elif defined(USE_PIPE)
    stdio_ipc_server _ipc;
#endif

public:
#if defined(USE_PIPE)
    win32compress_server(int fds2c, int fdc2s)
        : _ipc(fds2c, fdc2s)
#else
    win32compress_server()
#endif
    {
        csvrlog("server: reqsize=%d, ressize=%d\n", (int)sizeof(compressrequest), (int)sizeof(compressresult));
    }
    ~win32compress_server()
    {
    }

    bool server()
    {
        csvrlog("server: waiting for request\n");
        compressrequest  req;
        if (!_ipc.read(&req, sizeof(req)))
            return false;

        ByteVector indata(req.insize);
        if (!_ipc.read(&indata[0], indata.size()))
            return false;

        csvrlog("server: got request %d: %d bytes\n", req.dwType, req.insize);

        compressresult result;
        ByteVector outdata(req.outlength);

        switch(req.dwType)
        {
case ITSCOMP_XPR_DECODE:
case ITSCOMP_XPR_ENCODE:
case ITSCOMP_LZX_DECODE:
case ITSCOMP_LZX_ENCODE:
        result.resultLen= _lzxxpr.DoCompressConvert(req.dwType, &outdata[0], req.outlength, &indata[0], req.insize);
        break;
case ITSCOMP_ROM3_DECODE:
case ITSCOMP_ROM3_ENCODE:
case ITSCOMP_ROM4_DECODE:
case ITSCOMP_ROM4_ENCODE:
        result.resultLen= _rom34.DoCompressConvert(req.dwType, &outdata[0], req.outlength, &indata[0], req.insize);
        break;
        }

        csvrlog("server: sending reply %d bytes\n", result.resultLen);
        if (!_ipc.write(&result, sizeof(result)))
            return false;
        if (result.resultLen!=-1 && !_ipc.write(&outdata[0], result.resultLen))
            return false;
        return true;
    }
};
#endif
