#ifndef __SEMAIPC_H__
#define __SEMAIPC_H__

#include <semaphore.h>
#include "posixerr.h"
#include "util/atomicoperations.h"

template<typename T>
class unique_lock {
public:
    unique_lock(T& mtx) : _mtx(mtx), _locked(false) {
        lock();
    }
    ~unique_lock() {
        if (_locked)
            unlock();
    }
    void unlock() {
        if (_locked) {
            _mtx.unlock();
            _locked= false;
        }
    }
    void lock() {
        _mtx.lock();
        _locked= true;
    }
private:
    T &_mtx;
    bool _locked;
};
#if 0
class namedmutex {
    // todo: var + waits should be in shared memory
    enum { NOTLOCKED, LOCKED };
    int _var;
    int _waits;
    sem_t*_sem;
public:
    static void remove(const char*name) { sem_unlink(name); }
    namedmutex(const char*name, bool create)
        : _var(NOTLOCKED), _waits(0)
    {
        if (create)
            _sem= sem_open(name, O_CREAT, S_IRWXU | S_IRWXG, 1);
        else
            _sem= sem_open(name, 0);

        if (_sem==SEM_FAILED) 
            throw posixerror("semopen");
    }
    ~namedmutex()
    {
        sem_close(_sem);
    }
    void lock()
    {
        while (atomic_readwrite_if_equal(&_var, NOTLOCKED, LOCKED)!=NOTLOCKED) {
            atomic_increment(&_waits);
            if (-1==sem_wait(_sem))
                throw posixerror("semwait");
            atomic_decrement(&_waits);
        }
    }
    void unlock()
    {
        if (atomic_readwrite_if_equal(&_var, LOCKED, NOTLOCKED)!=LOCKED)
            throw "already unlocked";
        if (atomic_read(&_waits))
            if (-1==sem_post(_sem))
                throw posixerror("sempost");
    }
    typedef unique_lock<namedmutex> scoped_lock;
};
#endif
class namedmutex {
    sem_t*_sem;
public:
    static void remove(const char*name) { sem_unlink(name); }
    namedmutex(const char*name, bool create)
    {
        if (create)
            _sem= sem_open(name, O_CREAT, S_IRWXU | S_IRWXG, 1);
        else
            _sem= sem_open(name, 0);

        if (_sem==SEM_FAILED) 
            throw posixerror("semopen");
    }
    ~namedmutex()
    {
        sem_close(_sem);
    }
    void lock()
    {
        if (-1==sem_wait(_sem))
            throw posixerror("semwait");
    }
    void unlock()
    {
        if (-1==sem_post(_sem))
            throw posixerror("sempost");
    }
    typedef unique_lock<namedmutex> scoped_lock;
};
class namedcondition {
    namedmutex _mtx;
public:
    static void remove(const char*name) { namedmutex::remove(name); }
    namedcondition(const char *name, bool create)
        : _mtx(name, create)
    {
    }
    ~namedcondition() {
    }
    void notify_one() {
        _mtx.unlock();
    }
    void wait(namedmutex::scoped_lock& lck) {
        lck.unlock();
        _mtx.lock();
        lck.lock();
    }
};

#endif
