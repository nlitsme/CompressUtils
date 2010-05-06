#ifndef __POSIXERR_H__
#define __POSIXERR_H__
#include <stdio.h>
#include <errno.h>
class posixerror {
    const char* _msg;
    int _err;
public:
    posixerror(const char*msg) : _msg(msg), _err(errno)
    {
    }
    ~posixerror() { fprintf(stderr,"ERROR %d: %s\n", _err, _msg); }
};
#endif
