#ifndef __PSTREAM_IPC_H__
#define __PSTREAM_IPC_H__
#include "pstream.h"
#include <iostream>

class pstream_ipc_server {
public:
    pstream_ipc_server() { }
    ~pstream_ipc_server()
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
class pstream_ipc_client {
    redi::pstream _ps;
public:
    pstream_ipc_client()
        : _ps("compressserver")
    {
    }
    ~pstream_ipc_client()
    {
    }
    bool read(void*p, size_t n)
    {
        fprintf(stderr, "client-reading %d\n", n);
        _ps.read((char*)p, n);
        fprintf(stderr, "clt:read good=%d fail=%d eof=%d, bad=%d\n", _ps.good(), _ps.fail(), _ps.eof(), _ps.bad());
        return _ps.good();
    }
    bool write(const void *p, size_t n)
    {
        fprintf(stderr, "clt:writing %d\n", n);
        _ps.write((const char*)p, n);
        fprintf(stderr, "clt:wrote good=%d fail=%d eof=%d, bad=%d\n", _ps.good(), _ps.fail(), _ps.eof(), _ps.bad());
        return true;
    }
};
#endif
