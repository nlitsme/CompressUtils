#ifndef __SOCKET_IPC_SVR_H__
#define __SOCKET_IPC_SVR_H__
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "posixerr.h"
#include "readwriter.h"

class socket_ipc_server : public readwriter {
    struct sockaddr_in _peer;
    int _s;
    int _a;
public:
    socket_ipc_server()
    {
        _s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_s==-1)
            throw posixerror("socket");
        struct sockaddr_in inaddr;
        inaddr.sin_family = PF_INET;
        inaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        inaddr.sin_port = htons(6789);
        if (-1==bind(_s, (const sockaddr*)&inaddr, sizeof(inaddr)))
            throw posixerror("bind");
        if (-1==listen(_s, 1))
            throw posixerror("listen");

//      fprintf(stderr, "server-listening\n");
        socklen_t slen= sizeof(_peer);
        _a= accept(_s, (sockaddr*)&_peer, &slen);
        if (_a==-1)
            throw posixerror("accept");
//      fprintf(stderr, "server-accepted\n");
    }
    ~socket_ipc_server()
    {
        shutdown(_a, SHUT_RDWR);
        shutdown(_s, SHUT_RDWR);
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_a, p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_a, p, n);
    }
};
#endif
