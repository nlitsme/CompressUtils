#ifndef __BOOST_IPC_CLT_H__
#define __BOOST_IPC_CLT_H__

// note: boost ipc does not work between 32bit <-> 64bit processes

#ifdef _WIN32
#include <windows.h>
#endif
#include <boost/interprocess/shared_memory_object.hpp>
#include <boost/interprocess/mapped_region.hpp>
#include <boost/interprocess/sync/named_mutex.hpp>
#include <boost/interprocess/sync/scoped_lock.hpp>
#include <boost/interprocess/sync/named_condition.hpp>

#include "compress_shmem.h"
#include "stringutils.h"
#include <string>
#include <algorithm>
#include "posixerr.h"

#include "readwriter.h"
#include "forkchild.h"
#include "ipclog.h"

namespace ipc= boost::interprocess;

class boost_ipc_client : public readwriter, public fork_child {
    // note: mtx and cond must be named, you cannot share anon mutex between 32 and 64 bit app
    // note: this does not work either: internally they still use shmem
    ipc::named_mutex *_mtx;
    ipc::named_condition *_cond;
    ipc::shared_memory_object *_shm;
    ipc::mapped_region *_rgn;
    shmeminterface *_mem;
    void *_shdata;

    typedef ipc::scoped_lock<ipc::named_mutex> scopedlock;
public:
    boost_ipc_client(const std::string& svrname, const StringList& args)
        : _mtx(0), _cond(0), _shm(0), _rgn(0), _mem(0), _shdata(0)
    {
        ipclog("client: shm=%d, mtx=%d, cond=%d\n", sizeof(shmeminterface), sizeof(*_mtx), sizeof(*_cond));

        ipc::named_mutex::remove("compressmutex");
        _mtx= new ipc::named_mutex(ipc::create_only, "compressmutex");

        ipc::named_condition::remove("compresscond");
        _cond= new ipc::named_condition(ipc::create_only, "compresscond");

        ipc::shared_memory_object::remove("shared_memory");
        _shm= new ipc::shared_memory_object(ipc::create_only, "shared_memory", ipc::read_write);
        _shm->truncate(0x100000);
        _rgn= new ipc::mapped_region( *_shm, ipc::read_write, 0, 0x100000);
        _mem= new (_rgn->get_address()) shmeminterface;

        _shdata= (char*)_rgn->get_address()+sizeof(shmeminterface);

        run_child(svrname, args);

        // parent init
    }
    ~boost_ipc_client()
    {
        ipc::shared_memory_object::remove("shared_memory");
        ipc::named_mutex::remove("compressmutex");
        ipc::named_condition::remove("compresscond");
    }
    virtual size_t readsome(void*p, size_t n)
    {
        scopedlock lock(*_mtx);

        while (_mem->bufferstate!=BUF_HAS_DATA_FOR_CLIENT)
            _cond->wait(lock);

        size_t wanted= std::min(n, size_t(_mem->buffersize));
        memcpy(p, _shdata, wanted);
        _mem->buffersize -= wanted;
        _mem->bufferstart+= wanted;

        if (_mem->buffersize==0) {
            _mem->bufferstate= BUF_UNUSED;
            lock.unlock();
            _cond->notify_one();
        }
        return wanted;
    }
    virtual size_t writesome(const void*p, size_t n)
    {
        scopedlock lock(*_mtx);
        while (_mem->bufferstate!=BUF_UNUSED)
            _cond->wait(lock);

        size_t wanted= std::min(n, size_t(0xf0000));
        memcpy(_shdata, p, wanted);
        _mem->buffersize = wanted;
        _mem->bufferstart = 0;

        _mem->bufferstate= BUF_HAS_DATA_FOR_SERVER;
        lock.unlock();
        _cond->notify_one();
        return wanted;
    }
};

#endif

