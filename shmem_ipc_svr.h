#ifndef __SHMEM_IPC_SVR_H__
#define __SHMEM_IPC_SVR_H__

#include "compress_shmem.h"

#include "namedipc.h"

#include <algorithm>
#include "sharedmem.h"
#include "readwriter.h"
#include "ipclog.h"

class shmem_ipc_server : public readwriter {
    namedmutex _mtx;
    namedcondition _cond;

    sharedmem<shmeminterface> _shm;


public:
    shmem_ipc_server()
        : _mtx("/tmp/compresssema", false), _cond("/tmp/compresscond", false), _shm("/tmp/compressmem", 0x100000, false)
    {
        ipclog("server-shm=%d\n", sizeof(shmeminterface));
    }
    ~shmem_ipc_server()
    {
    }
    virtual size_t readsome(void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_shm.ptr()->bufferstate!=BUF_HAS_DATA_FOR_SERVER)
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

        _shm.ptr()->bufferstate= BUF_HAS_DATA_FOR_CLIENT;
        lock.unlock();
        _cond.notify_one();
        return wanted;
    }
};

#endif



