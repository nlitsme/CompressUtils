#ifndef __PSTREAM_IPC_H__
#define __PSTREAM_IPC_H__
#include "pstream.h"
#include <iostream>

#include "stringutils.h"

class pstream_ipc_client {
    redi::pstream _ps;
public:
    pstream_ipc_client(const std::string& svrname, const StringList& args)
        : _ps(svrname, args)
    {
    }
    ~pstream_ipc_client()
    {
    }
    bool read(void*p, size_t n)
    {
        fprintf(stderr, "client-reading %d\n", (int)n);
        _ps.read((char*)p, n);
        fprintf(stderr, "clt:read good=%d fail=%d eof=%d, bad=%d\n", _ps.good(), _ps.fail(), _ps.eof(), _ps.bad());
        return _ps.good();
    }
    bool write(const void *p, size_t n)
    {
        fprintf(stderr, "clt:writing %d\n", (int)n);
        _ps.write((const char*)p, n);
        fprintf(stderr, "clt:wrote good=%d fail=%d eof=%d, bad=%d\n", _ps.good(), _ps.fail(), _ps.eof(), _ps.bad());
        return true;
    }
};
#endif
