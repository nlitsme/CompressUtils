#ifndef __PSTREAM_IPC_H__
#define __PSTREAM_IPC_H__
#include "pstream.h"
#include <iostream>

#include "stringutils.h"
#include "readwriter.h"

class pstream_ipc_client : public readwriter {
    redi::pstream _ps;
public:
    pstream_ipc_client(const std::string& svrname, const StringList& args)
        : _ps(svrname, args)
    {
    }
    ~pstream_ipc_client()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        _ps.read((char*)p, n);
        return _ps.good() ? n : -1;
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        _ps.write((const char*)p, n);
        return _ps.good() ? n : -1;
    }
};
#endif
