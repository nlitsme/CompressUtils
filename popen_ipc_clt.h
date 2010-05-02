#ifndef __POPEN_IPC_H__
#define __POPEN_IPC_H__
#include <stdio.h>
#include "stringutils.h"

#define ipclog(...)
class popen_ipc_client {
    FILE *_pipe;
public:
    popen_ipc_client(const std::string& svrname, const StringList& args)
    {
        std::string cmdline= svrname+" "+JoinStringList(args, " ");
        _pipe= popen(cmdline.c_str(), "r+");
        if (_pipe==NULL)
            perror("popen");
    }
    ~popen_ipc_client()
    {
    }
    bool read(void*p, size_t n)
    {
        ipclog("client-reading %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= fread((char*)p+total, 1, n-total, _pipe);
            if (r==-1) {
                perror("clt-fread");
                return false;
            }
            total += r;
        }
        ipclog("clt:read\n");
        return true;
    }
    bool write(const void *p, size_t n)
    {
        ipclog("clt:writing %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= fwrite((const char*)p+total, 1, n-total, _pipe);
            if (r==-1) {
                perror("clt-fwrite");
                return false;
            }
            total += r;
        }
        ipclog("clt:wrote\n");
        return true;
    }
};
#endif
