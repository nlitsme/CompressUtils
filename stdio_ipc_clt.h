#ifndef __STDIO_IPC_H__
#define __STDIO_IPC_H__
#include <stdio.h>
#include "stringutils.h"
#include "err/posix.h"
#include "readwriter.h"
#include "ipclog.h"

class stdio_ipc_client : public readwriter {
public:
    stdio_ipc_client(const std::string& svrname, const StringList& args)
    {
        std::string cmdline= svrname+" "+JoinStringList(args, " ");
        printf("NOT opening %s\n", cmdline.c_str());
    }
    ~stdio_ipc_client()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return fread(p, 1, 1, stdin);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return fwrite(p, 1, n, stdout);
    }
};
#endif

