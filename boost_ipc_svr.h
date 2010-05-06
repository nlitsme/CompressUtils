#ifndef __BOOST_IPC_SVR_H__
#define __BOOST_IPC_SVR_H__

// note: boost ipc does not work between 32bit <-> 64bit processes

#include <boost/interprocess/shared_memory_object.hpp>
#include <boost/interprocess/mapped_region.hpp>
#include <boost/interprocess/sync/named_mutex.hpp>
#include <boost/interprocess/sync/scoped_lock.hpp>
#include <boost/interprocess/sync/named_condition.hpp>

#include "compress_shmem.h"

namespace ipc= boost::interprocess;

//#define ipclog(...) fprintf(stderr,__VA_ARGS__)
#define ipclog(...)

class boost_ipc_server {
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
    boost_ipc_server()
        : _mtx(0), _cond(0), _shm(0), _rgn(0), _mem(0), _shdata(0)
    {
        ipclog("server: shm=%d, mtx=%d, cond=%d\n", sizeof(shmeminterface), sizeof(*_mtx), sizeof(*_cond));

        _mtx= new ipc::named_mutex(ipc::open_only, "compressmutex");
        _cond= new ipc::named_condition(ipc::open_only, "compresscond");

        _shm= new ipc::shared_memory_object(ipc::open_only, "shared_memory", ipc::read_write);
        _shm->truncate(0x100000);
        _rgn= new ipc::mapped_region( *_shm, ipc::read_write, 0, 0x100000);
        _mem= static_cast<shmeminterface*>(_rgn->get_address());
        _shdata= (char*)_rgn->get_address()+sizeof(shmeminterface);
    }
    ~boost_ipc_server()
    {
    }
    size_t readsome(void*p, size_t n)
    {
        scopedlock lock(*_mtx);

        while (_mem->bufferstate!=BUF_HAS_DATA_FOR_SERVER)
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
    size_t writesome(const void*p, size_t n)
    {
        scopedlock lock(*_mtx);
        while (_mem->bufferstate!=BUF_UNUSED)
            _cond->wait(lock);

        size_t wanted= std::min(n, size_t(0xf0000));
        memcpy(_shdata, p, wanted);
        _mem->buffersize = wanted;
        _mem->bufferstart = 0;

        _mem->bufferstate= BUF_HAS_DATA_FOR_CLIENT;
        lock.unlock();
        _cond->notify_one();
        return wanted;
    }

    bool read(void*p, size_t n)
    {
        ipclog("server-reading %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= readsome((char*)p+total, n-total);
            if (r==-1) {
                perror("svr-read");
                return false;
            }
            total += r;
        }
        ipclog("server-read %d\n", (int)n);
        return true;
    }
    bool write(const void*p, size_t n)
    {
        ipclog("server-writing %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= writesome((const char*)p+total, n-total);
            if (r==-1)
            {
                perror("svr-write");
                return false;
            }
            total += r;
        }
        ipclog("server-wrote %d\n", (int)n);
        return true;
    }

};

#endif


