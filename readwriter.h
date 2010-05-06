#ifndef __READWRITER_H__
#define __READWRITER_H__

#include <stdio.h>
#include "ipclog.h"

class readwriter {
public:
    virtual ~readwriter() { }
    virtual size_t readsome(void*p, size_t n)= 0;
    virtual size_t writesome(const void*p, size_t n)= 0;
    bool read(void*p, size_t n)
    {
        ipclog("reading %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= readsome((char*)p+total, n-total);
            if (r==-1) {
                perror("read");
                return false;
            }
            total += r;
        }
        ipclog("read %d\n", (int)n);
        return true;
    }
    bool write(const void*p, size_t n)
    {
        ipclog("writing %d\n", (int)n);
        size_t total= 0;
        while (total<n)
        {
            int r= writesome((const char*)p+total, n-total);
            if (r==-1)
            {
                perror("write");
                return false;
            }
            total += r;
        }
        ipclog("wrote %d\n", (int)n);
        return true;
    }
};
#endif
