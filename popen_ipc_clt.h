#ifndef __POPEN_IPC_H__
#define __POPEN_IPC_H__
#include <stdio.h>
#include "stringutils.h"
#include "posixerr.h"
#include "readwriter.h"
#include "ipclog.h"

class popen_ipc_client : public readwriter {
    FILE *_pipe;
public:
    popen_ipc_client(const std::string& svrname, const StringList& args)
    {
        std::string cmdline= svrname+" "+JoinStringList(args, " ");
        _pipe= popen(cmdline.c_str(), "r+");
        if (_pipe==NULL)
            throw posixerror("clt:popen");
    }
    ~popen_ipc_client()
    {
        // todo: figure out pid of other end of pipe, and kill it
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return fread(p, 1, n, _pipe);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return fwrite(p, 1, n, _pipe);
    }
};
#endif
