#ifndef __PTY_IPC_CLT_H__
#define __PTY_IPC_CLT_H__
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "stringutils.h"
#include "posixerr.h"
#include "readwriter.h"


class pty_ipc_server : public readwriter {
public:
    pty_ipc_server()
    {
    }
    ~pty_ipc_server()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        // todo
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        // todo
    }
}
