#ifndef __SOCKET_IPC_CLT_H__
#define __SOCKET_IPC_CLT_H__
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "stringutils.h"
#include "err/posix.h"
#include "readwriter.h"
#include "forkchild.h"
#include "ipclog.h"

class socket_ipc_client : public readwriter, public fork_child {
    int _s;
public:
    socket_ipc_client(const std::string& svrname, const StringList& args)
        : _s(0)
    {
        run_child(svrname, args);

        sleep(1);
        _s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_s==-1)
            throw posixerror("socket");
        struct sockaddr_in inaddr;
        inaddr.sin_family = PF_INET;
        inaddr.sin_addr.s_addr = htonl(0x7f000001);
        inaddr.sin_port = htons(6789);
        if (-1==connect(_s, (const sockaddr*)&inaddr, sizeof(inaddr)))
            throw posixerror("connect");
        ipclog(stderr, "client connected\n");
    }
    ~socket_ipc_client()
    {
        shutdown(_s, SHUT_RDWR);
    }

    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_s, p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_s, p, n);
    }
};

#endif

