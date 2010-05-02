#ifndef __SOCKET_IPC_CLT_H__
#define __SOCKET_IPC_CLT_H__
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "stringutils.h"

class socket_ipc_client {
    int _s;
public:
    socket_ipc_client(const std::string& svrname, const StringList& args)
    {
        std::string cmdline= svrname+" "+JoinStringList(args, " ")+"&";
        system(cmdline.c_str());
        sleep(1);
        _s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (_s==-1)
            perror("socket");
        struct sockaddr_in inaddr;
        inaddr.sin_family = PF_INET;
        inaddr.sin_addr.s_addr = htonl(0x7f000001);
        inaddr.sin_port = htons(6789);
        if (-1==connect(_s, (const sockaddr*)&inaddr, sizeof(inaddr)))
            perror("connect");
//      fprintf(stderr, "client connected\n");
    }
    ~socket_ipc_client()
    {
        shutdown(_s, SHUT_RDWR);
    }
    bool read(void*p, size_t n)
    {
//      fprintf(stderr, "client reading %d\n", n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_s, (char*)p+total, n-total);
            if (r==-1)
                return false;
            total += r;
//          if (r)
//              fprintf(stderr, "client-read %d of %d\n", r, n);
        }
        return true;
    }

    bool write(const void*p, size_t n)
    {
//      fprintf(stderr, "client write %d\n", n);
        if (-1==::write(_s, (const char*)p, n))
            return false;
//      fprintf(stderr, "client wrote\n");
        return true;
    }
};

#endif

