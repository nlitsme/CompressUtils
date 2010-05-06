#ifndef __SHAREDMEM__H__
#define __SHAREDMEM__H__

#include <sys/mman.h>

template<typename T>
class sharedmem {
    const char*_name;
    size_t _size;
    bool _creator;

    int _memfd;
    void *_addr;
    T *_mem;

public:
    sharedmem(const char*name, size_t size, bool create)
        : _name(name), _size(size), _creator(create),
            _memfd(-1), _addr(0), _mem(0)
    {
        _memfd= shm_open(name, (create?O_CREAT:0)|O_RDWR, S_IRWXU | S_IRWXG);
        if (_memfd==-1) 
            throw posixerror("open(shmem)");

        ftruncate(_memfd, _size);

        _addr= mmap(0, _size, PROT_WRITE|PROT_READ, MAP_SHARED, _memfd, 0);
        if (_addr==NULL) 
            throw posixerror("clt:mmap");

        if (_creator)
            _mem= new(_addr) T;
        else
            _mem= reinterpret_cast<T*>(_addr);
    }
    ~sharedmem()
    {
        if (_creator)
            _mem->~T();
        munmap(_addr, _size);
        close(_memfd);
        if (_creator)
            shm_unlink(_name);
    }
    T* ptr() { return _mem; }
    void *data() { return ((char*)_mem)+sizeof(T); }
};

#endif
