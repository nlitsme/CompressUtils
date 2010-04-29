#ifndef _WIN32COMPRESS_CLIENT_
#define _WIN32COMPRESS_CLIENT_
#include <stdio.h>
#include <string.h>
#include "wintypes.h"
// note: see http://pstreams.sourceforge.net/  for a better bidirectional pipe

#include "compress_ipc.h"

#if defined(USE_POPEN)
#include "popen_ipc.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc.h"
#elif defined(USE_SOCKET)
#include "socket_ipc.h"
#endif
class win32compress_client {
#if defined(USE_POPEN)
    popen_ipc_client _ipc;
#elif defined(USE_PSTREAM)
    pstream_ipc_client _ipc;
#elif defined(USE_SOCKET)
    socket_ipc_client _ipc;
#endif
public:
    win32compress_client()
    {
//      fprintf(stderr, "compressclient started server, reqsize=%d, ressize=%d\n", (int)sizeof(compressrequest), (int)sizeof(compressresult));
    }
    void loaddlls()
    {
    }
    DWORD DoCompressConvert(int dwType, unsigned char*out, DWORD outlength, const unsigned char *data, DWORD insize)
    {
        compressrequest  req;
        req.dwType          =dwType;
        req.outlength       =outlength;
        req.insize          =insize;
        memcpy(req.data, data, insize);

        compressresult result;
        if (!makerequest(req, result))
            return 0xFFFFFFFF;

        if (result.resultLen==0xFFFFFFFF)
            return 0xFFFFFFFF;

        memcpy(out, result.out, result.resultLen);

        return result.resultLen;
    }

    bool makerequest(const compressrequest  &req, compressresult &result)
    {
//      fprintf(stderr,"client: sending request : %d: %d bytes\n", req.dwType, req.insize);
        if (!_ipc.write(&req, sizeof(req)))
            return false;
//      fprintf(stderr,"client: waiting for result\n");
        if (!_ipc.read(&result, sizeof(result)))
            return false;
//      fprintf(stderr,"client: got result: %d bytes\n", result.resultLen);
        return true;
    }
};
#endif
