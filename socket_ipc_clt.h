#ifndef __SOCKET_IPC_CLT_H__
#define __SOCKET_IPC_CLT_H__
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <stdio.h>

#include "stringutils.h"
#include "posixerr.h"

//#define ipclog(...) fprintf(stderr,__VA_ARGS__)
#define ipclog(...)
class socket_ipc_client {
    std::string _svrname;
    StringList _args;
    int _s;
    int _pid;
public:
    socket_ipc_client(const std::string& svrname, const StringList& args)
        : _svrname(svrname), _args(args), _s(0), _pid(0)
    {
        _pid= fork();
        if (-1==_pid) 
            throw posixerror("clt:fork");
        if (_pid==0) {
            ipclog("child(server)\n");
            run_child();
        }
        ipclog("parent(client) ( svr=%d )\n", _pid);

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
        kill(_pid, SIGTERM);
    }
    void run_child()
    {
        // construct argv

        char**argv= (char**)malloc((_args.size()+2)*sizeof(char*));
        argv[0]= &_svrname[0];
        for (unsigned i=0 ; i<_args.size() ; i++)
            argv[i+1]= &_args[i][0];
        argv[_args.size()+1]= 0;

        execvp(_svrname.c_str(), argv);

        fprintf(stderr, "failed to exec %s\n", _svrname.c_str());
        throw posixerror("clt:exec");
    }
    bool read(void*p, size_t n)
    {
        ipclog("client-reading %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_s, (char*)p+total, n-total);
            if (r==-1) {
                perror("clt-read");
                return false;
            }
            total += r;
        }
        ipclog("client-read %d\n", (int)n);
        return true;
    }
    bool write(const void*p, size_t n)
    {
        ipclog("client-writing %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::write(_s, (const char*)p+total, n-total);
            if (r==-1)
            {
                perror("clt-write");
                return false;
            }
            total += r;
        }
        ipclog("client-wrote %d\n", (int)n);
        return true;
    }

};

#endif

