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
#endif

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
#endif
public:
    std::string serverpath()
    {
        std::string prog= getprogname();
        fprintf(stderr, "\n\n* %s", prog.c_str());
        size_t ix= prog.find_last_of("/");
        if (ix==std::string::npos)
            return "./compressserver";
        prog.resize(ix+1);
        prog += "compressserver";
        fprintf(stderr, " - %s\n\n", prog.c_str());
            
        return prog;
    }
    win32compress_client()
        : _ipc(serverpath(), StringList())
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
//      ccltlog("client: sending request : %d: %d bytes\n", req.dwType, req.insize);
        if (!_ipc.write(&req, sizeof(req)))
            return false;
//      ccltlog("client: waiting for result\n");
        if (!_ipc.read(&result, sizeof(result)))
            return false;
//      ccltlog("client: got result: %d bytes\n", result.resultLen);
        return true;
    }
};
#endif
