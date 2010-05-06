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
#include <signal.h>
#include "posixerr.h"

namespace ipc= boost::interprocess;

//#define ipclog(...) fprintf(stderr,__VA_ARGS__)
#define ipclog(...)

class boost_ipc_client {
    // note: mtx and cond must be named, you cannot share anon mutex between 32 and 64 bit app
    // note: this does not work either: internally they still use shmem
    ipc::named_mutex *_mtx;
    ipc::named_condition *_cond;
    ipc::shared_memory_object *_shm;
    ipc::mapped_region *_rgn;
    shmeminterface *_mem;
    void *_shdata;

    std::string _svrname;
    StringList _args;
    int _pid;

    typedef ipc::scoped_lock<ipc::named_mutex> scopedlock;
public:
    boost_ipc_client(const std::string& svrname, const StringList& args)
        : _mtx(0), _cond(0), _shm(0), _rgn(0), _mem(0), _shdata(0), _svrname(svrname), _args(args), _pid(0)
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
#ifdef _WIN32
        run_child();
#else
        _pid= fork();
        if (-1==_pid) 
            throw posixerror("clt:fork");
        if (_pid==0) {
            ipclog("child(server)\n");
            run_child();
        }
#endif
        ipclog("parent(client) ( svr=%d )\n", _pid);

        // parent
    }
    ~boost_ipc_client()
    {
#ifndef _WIN32
        kill(_pid, SIGTERM);
#endif
        ipc::shared_memory_object::remove("shared_memory");
        ipc::named_mutex::remove("compressmutex");
        ipc::named_condition::remove("compresscond");
    }
    void run_child()
    {
#ifndef _WIN32
        // construct argv

        char**argv= (char**)malloc((_args.size()+2)*sizeof(char*));
        argv[0]= &_svrname[0];
        for (unsigned i=0 ; i<_args.size() ; i++)
            argv[i+1]= &_args[i][0];
        argv[_args.size()+1]= 0;

        execvp(_svrname.c_str(), argv);

        fprintf(stderr, "failed to exec %s\n", _svrname.c_str());
        throw posixerror("clt:exec");
#else
        PROCESS_INFORMATION procinfo;

        STARTUPINFO startinfo;
        memset(&startinfo, 0, sizeof(STARTUPINFO));
        startinfo.cb= sizeof(STARTUPINFO);

        if (!CreateProcess((char*)_svrname.c_str(), (char*)JoinStringList(_args, " ").c_str(), 0, 0, 0, 0, 0, 0, &startinfo, &procinfo))
            fprintf(stderr, "error creating process: 0x%x\n", GetLastError());
        else {
            CloseHandle (procinfo.hThread);
            CloseHandle (procinfo.hProcess);
        }
#endif
    }
    size_t readsome(void*p, size_t n)
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
    size_t writesome(const void*p, size_t n)
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

