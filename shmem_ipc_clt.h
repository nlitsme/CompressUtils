#ifndef __SHMEM_IPC_CLT_H__
#define __SHMEM_IPC_CLT_H__

#include "compress_shmem.h"
#include "stringutils.h"
#include "namedipc.h"
#include <string>
#include <algorithm>
#include <signal.h>
#include <unistd.h>
#include <sys/mman.h>

//#define ipclog(...) fprintf(stderr,__VA_ARGS__)
#define ipclog(...)

class shmem_ipc_client {
    class remover {
        public:
        remover()
        {
            namedmutex::remove("compresssema");
            namedcondition::remove("compresscond");
        }
    };
    remover  _rmv;
    namedmutex _mtx;
    namedcondition _cond;
    int _memfd;
    shmeminterface *_mem;
    void *_shdata;

    std::string _svrname;
    StringList _args;
    int _pid;

public:
    shmem_ipc_client(const std::string& svrname, const StringList& args)
        : _mtx("/tmp/compresssema", true), _cond("/tmp/compresscond", true), _memfd(0), _mem(0), _shdata(0), _svrname(svrname), _args(args), _pid(0)
    {
        ipclog("client-shm=%d\n", sizeof(shmeminterface));

        _memfd= shm_open("/tmp/compressshmem", O_CREAT|O_RDWR, S_IRWXU | S_IRWXG);
        if (_memfd==-1) 
            throw posixerror("clt:open(shmem)");

        ftruncate(_memfd, 0x100000);

        void *addr= mmap(0, 0x100000, PROT_WRITE|PROT_READ, MAP_SHARED, _memfd, 0);
        if (addr==NULL) 
            throw posixerror("clt:mmap");

        _mem= new (addr) shmeminterface;

        _shdata= (char*)addr+sizeof(shmeminterface);

        _pid= fork();
        if (-1==_pid) 
            throw posixerror("clt:fork");
        if (_pid==0) {
            ipclog("child(server)\n");
            run_child();
        }
        ipclog("parent(client) ( svr=%d )\n", _pid);

        // parent
    }
    ~shmem_ipc_client()
    {
        kill(_pid, SIGTERM);
    }
    void run_child()
    {
        // construct argv

        char**argv= (char**)malloc((_args.size()+2)*sizeof(char*));
        argv[0]= &_svrname[0];
        for (unsigned i=0 ; i<_args.size() ; i++)
            argv[i+1]= &_args[i][0];
        argv[_args.size()+1]= 0;

        execvp(_svrname.c_str(), argv);

        fprintf(stderr, "failed to exec %s\n", _svrname.c_str());
        throw posixerror("clt:exec");
    }
    size_t readsome(void*p, size_t n)
    {
        namedmutex::scoped_lock lock(_mtx);

        while (_mem->bufferstate!=BUF_HAS_DATA_FOR_CLIENT)
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

        _mem->bufferstate= BUF_HAS_DATA_FOR_SERVER;
        lock.unlock();
        _cond.notify_one();
        return wanted;
    }

    bool read(void*p, size_t n)
    {
        ipclog("client-reading %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= readsome((char*)p+total, n-total);
            if (r==-1) {
                perror("clt-read");
                return false;
            }
            total += r;
        }
        ipclog("client-read %d\n", (int)n);
        return true;
    }
    bool write(const void*p, size_t n)
    {
        ipclog("client-writing %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= writesome((const char*)p+total, n-total);
            if (r==-1)
            {
                perror("clt-write");
                return false;
            }
            total += r;
        }
        ipclog("client-wrote %d\n", (int)n);
        return true;
    }
};

#endif


