#ifndef _WIN32COMPRESS_CLIENT_
#define _WIN32COMPRESS_CLIENT_
#include <stdio.h>
#include <string.h>
#include "wintypes.h"
// note: see http://pstreams.sourceforge.net/  for a better bidirectional pipe

#include "compress_msgs.h"

#if defined(USE_POPEN)
#include "popen_ipc_clt.h"
#elif defined(USE_PSTREAM)
#include "pstream_ipc_clt.h"
#elif defined(USE_SOCKET)
#include "socket_ipc_clt.h"
#elif defined(USE_PIPE)
#include "pipe_ipc_clt.h"
#elif defined(USE_BOOST)
#include "boost_ipc_clt.h"
#elif defined(USE_SHMEM)
#include "shmem_ipc_clt.h"
#endif

//#define ccltlog(...) fprintf(stderr, __VA_ARGS__)
#define ccltlog(...)

class win32compress_client {
#if defined(USE_POPEN)
    popen_ipc_client _ipc;
#elif defined(USE_PSTREAM)
    pstream_ipc_client _ipc;
#elif defined(USE_SOCKET)
    socket_ipc_client _ipc;
#elif defined(USE_PIPE)
    pipe_ipc_client _ipc;
#elif defined(USE_BOOST)
    boost_ipc_client _ipc;
#elif defined(USE_SHMEM)
    shmem_ipc_client _ipc;
#endif
public:

    win32compress_client()
        : _ipc("compressserver", StringList())
    {
//      ccltlog("compressclient started server, reqsize=%d, ressize=%d\n", (int)sizeof(compressrequest), (int)sizeof(compressresult));
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

        if (!_ipc.write(&req, sizeof(req)))
            return 0xFFFFFFFF;
        if (!_ipc.write(data, insize))
            return 0xFFFFFFFF;

        compressresult result;
        if (!_ipc.read(&result, sizeof(result)))
            return 0xFFFFFFFF;
        if (result.resultLen==0xFFFFFFFF)
            return 0xFFFFFFFF;

        if (!_ipc.read(out, result.resultLen))
            return 0xFFFFFFFF;

        return result.resultLen;
    }

    bool makerequest(const compressrequest  &req, compressresult &result)
    {
//      ccltlog("client: sending request : %d: %d bytes\n", req.dwType, req.insize);
//      ccltlog("client: got result: %d bytes\n", result.resultLen);
        return true;
    }
};
#endif
