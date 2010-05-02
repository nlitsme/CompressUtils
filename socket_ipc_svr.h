#ifndef __SOCKET_IPC_SVR_H__
#define __SOCKET_IPC_SVR_H__
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
class socket_ipc_server {
    struct sockaddr_in _peer;
    int _s;
    int _a;
public:
    socket_ipc_server()
    {
        _s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_s==-1)
            perror("socket");
        struct sockaddr_in inaddr;
        inaddr.sin_family = PF_INET;
        inaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        inaddr.sin_port = htons(6789);
        if (-1==bind(_s, (const sockaddr*)&inaddr, sizeof(inaddr)))
            perror("bind");
        if (-1==listen(_s, 1))
            perror("listen");

//      fprintf(stderr, "server-listening\n");
        socklen_t slen= sizeof(_peer);
        _a= accept(_s, (sockaddr*)&_peer, &slen);
        if (_a==-1)
            perror("accept");
//      fprintf(stderr, "server-accepted\n");
    }
    ~socket_ipc_server()
    {
        shutdown(_a, SHUT_RDWR);
        shutdown(_s, SHUT_RDWR);
    }
    bool read(void*p, size_t n)
    {
//      fprintf(stderr, "server-reading %d\n", n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_a, (char*)p+total, n-total);
            if (r==-1)
                return false;
            total += r;
//          if (r)
//              fprintf(stderr, "server-read %d of %d\n", r, n);
        }
        return true;
    }

    bool write(const void*p, size_t n)
    {
//      fprintf(stderr, "server-write %d\n", n);
        if (-1==::write(_a, (const char*)p, n))
            return false;
//      fprintf(stderr, "server-wrote\n");
        return true;
    }
};
#endif
