#ifndef __PIPE_IPC_H__
#define __PIPE_IPC_H__
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include "stringutils.h"

#define ipclog(...)
//#define ipclog(...) fprintf(stderr,__VA_ARGS__)

class pipe_ipc_client {
    std::string _svrname;
    StringList _args;

    int _fds2c[2];
    int _fdc2s[2];
    int _pid;
public:
    pipe_ipc_client(const std::string& svrname, const StringList& args)
        : _svrname(svrname), _args(args)
    {
        if (-1==pipe(_fds2c)) {
            perror("pipe-s2c");
            exit(1);
        }
        ipclog("s2c: %d, %d\n", _fds2c[0], _fds2c[1]);
        if (-1==pipe(_fdc2s)) {
            perror("pipe-c2s");
            exit(1);
        }
        ipclog("c2s: %d, %d\n", _fdc2s[0], _fdc2s[1]);
        _pid= fork();
        if (-1==_pid) {
            perror("fork");
            exit(1);
        }
        if (_pid==0) {
            ipclog("child(server)\n");
            run_child();
        }
        ipclog("parent(client) ( svr=%d )\n", _pid);

        // parent

//      close(_fdc2s[0]);
//      close(_fds2c[1]);
    }
    ~pipe_ipc_client()
    {
        kill(_pid, SIGTERM);
    }
    void run_child()
    {
        if (-1==dup2(_fdc2s[0],STDIN_FILENO)) {
            perror("dup2(stdin)");
            exit(1);
        }
        if (-1==dup2(_fds2c[1],STDOUT_FILENO)) {
            perror("dup2(stdout)");
            exit(1);
        }
        ipclog("svr: %d->stdin, %d->stdout\n", _fdc2s[0], _fds2c[1]);

        close(_fdc2s[0]);
        close(_fdc2s[1]);
        close(_fds2c[0]);
        close(_fds2c[1]);

        // construct argv

        char**argv= (char**)malloc((_args.size()+2)*sizeof(char*));
        argv[0]= &_svrname[0];
        for (unsigned i=0 ; i<_args.size() ; i++)
            argv[i+1]= &_args[i][0];
        argv[_args.size()+1]= 0;

        execvp(_svrname.c_str(), argv);

        perror("exec");
        exit(1);
    }
    bool read(void*p, size_t n)
    {
        ipclog("client-reading(%d) %d\n", _fds2c[0], (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= ::read(_fds2c[0], (char*)p+total, n-total);
            if (r==-1) {
                perror("clt-read");
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
            int r=::write(_fdc2s[1], (const char*)p+total, n-total);
            if (r==-1)
            {
                perror("clt-write");
                return false;
            }
            total += r;
        }

        ipclog("clt:wrote\n");
        return true;
    }
};
#endif
