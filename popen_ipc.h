#ifndef __POPEN_IPC_H__
#define __POPEN_IPC_H__
#include <stdio.h>
class popen_ipc_server {
public:
    popen_ipc_server() { }
    ~popen_ipc_server()
    {
        fclose(stdin);
        fclose(stdout);
    }
    bool read(void*p, size_t n)
    {
        fprintf(stderr, "server-reading %d\n", n);
        if (1!=fread(p, n, 1, stdin)) {
            perror("svr-fread");
            return false;
        }
        fprintf(stderr, "server-read %d\n", n);
        return true;
    }

    bool write(const void*p, size_t n)
    {
        fprintf(stderr, "server-writing %d\n", n);
        if (1!=fwrite(p, n, 1, stdout)) {
            perror("svr-fwrite");
            return false;
        }
        fprintf(stderr, "server-wrote %d\n", n);
        return true;
    }
};
class popen_ipc_client {
    FILE *_pipe;
public:
    popen_ipc_client()
    {
        _pipe= popen("compressserver", "r+");
        if (_pipe==NULL)
            perror("popen");
    }
    ~popen_ipc_client()
    {
    }
    bool read(void*p, size_t n)
    {
        fprintf(stderr, "client-reading %d\n", n);
        if (1!=fread(p, n, 1, stdin)) {
            perror("clt-fread");
            return false;
        }
        fprintf(stderr, "clt:read\n");
        return true;
    }
    bool write(const void *p, size_t n)
    {
        fprintf(stderr, "clt:writing %d\n", n);
        if (1!=fwrite(p, n, 1, _pipe)) {
            perror("clt-fwrite");
            return false;
        }
        fprintf(stderr, "clt:wrote\n", n);
        return true;
    }
};
#endif
