#ifndef __SHMEM_IPC_SVR_H__
#define __SHMEM_IPC_SVR_H__

#include "compress_shmem.h"

#include "namedipc.h"
#include <sys/mman.h>
#include <algorithm>

//#define ipclog(...) fprintf(stderr,__VA_ARGS__)
#define ipclog(...)


class shmem_ipc_server {
    namedmutex _mtx;
    namedcondition _cond;
    int _memfd;
    shmeminterface *_mem;
    void *_shdata;


public:
    shmem_ipc_server()
        : _mtx("/tmp/compresssema", false), _cond("/tmp/compresscond", false), _memfd(0), _mem(0), _shdata(0)
    {
        ipclog("server-shm=%d\n", sizeof(shmeminterface));

        _memfd= shm_open("/tmp/compressshmem", O_RDWR, S_IRWXU | S_IRWXG);
        if (_memfd==-1) 
            throw posixerror("svr:open(shmem)");
        void *addr= mmap(0, 0x100000, PROT_WRITE|PROT_READ, MAP_SHARED, _memfd, 0);
        if (addr==NULL) 
            throw posixerror("svr:mmap");

        _mem= static_cast<shmeminterface*>(addr);

        _shdata= (char*)addr+sizeof(shmeminterface);
    }
    ~shmem_ipc_server()
    {
    }
    size_t readsome(void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_mem->bufferstate!=BUF_HAS_DATA_FOR_SERVER)
            _cond.wait(lock);

        size_t wanted= std::min(n, size_t(_mem->buffersize));
        memcpy(p, _shdata, wanted);
        _mem->buffersize -= wanted;
        _mem->bufferstart+= wanted;

        if (_mem->buffersize==0) {
            _mem->bufferstate= BUF_UNUSED;
            lock.unlock();
            _cond.notify_one();
        }
        return wanted;
    }
    size_t writesome(const void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_mem->bufferstate!=BUF_UNUSED)
            _cond.wait(lock);

        size_t wanted= std::min(n, size_t(0xf0000));
        memcpy(_shdata, p, wanted);
        _mem->buffersize = wanted;
        _mem->bufferstart = 0;

        _mem->bufferstate= BUF_HAS_DATA_FOR_CLIENT;
        lock.unlock();
        _cond.notify_one();
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



