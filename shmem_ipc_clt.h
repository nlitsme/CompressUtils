#ifndef __SHMEM_IPC_CLT_H__
#define __SHMEM_IPC_CLT_H__

#include "compress_shmem.h"
#include "stringutils.h"
#include "namedipc.h"
#include <string>
#include <algorithm>
#include <unistd.h>

#include "sharedmem.h"
#include "readwriter.h"
#include "forkchild.h"
#include "ipclog.h"

class shmem_ipc_client : public readwriter, public fork_child {
    class remover {
        public:
        remover()
        {
            namedmutex::remove("/tmp/compresssema");
            namedcondition::remove("/tmp/compresscond");
        }
    };
    remover  _rmv;
    namedmutex _mtx;
    namedcondition _cond;

    sharedmem<shmeminterface> _shm;

public:
    shmem_ipc_client(const std::string& svrname, const StringList& args)
        : _mtx("/tmp/compresssema", true), _cond("/tmp/compresscond", true), _shm("/tmp/compressmem", 0x100000, true)
    {
        ipclog("client-shm=%d\n", sizeof(shmeminterface));

        run_child(svrname, args);

        // parent
    }
    ~shmem_ipc_client()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_shm.ptr()->bufferstate!=BUF_HAS_DATA_FOR_CLIENT)
            _cond.wait(lock);

        size_t wanted= std::min(n, size_t(_shm.ptr()->buffersize));
        memcpy(p, _shm.data(), wanted);
        _shm.ptr()->buffersize -= wanted;
        _shm.ptr()->bufferstart+= wanted;

        if (_shm.ptr()->buffersize==0) {
            _shm.ptr()->bufferstate= BUF_UNUSED;
            lock.unlock();
            _cond.notify_one();
        }
        return wanted;
    }
    virtual size_t writesome(const void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_shm.ptr()->bufferstate!=BUF_UNUSED)
            _cond.wait(lock);

        size_t wanted= std::min(n, size_t(0xf0000));
        memcpy(_shm.data(), p, wanted);
        _shm.ptr()->buffersize = wanted;
        _shm.ptr()->bufferstart = 0;

        _shm.ptr()->bufferstate= BUF_HAS_DATA_FOR_SERVER;
        lock.unlock();
        _cond.notify_one();
        return wanted;
    }

};

#endif


