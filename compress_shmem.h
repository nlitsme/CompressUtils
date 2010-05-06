#ifndef __COMPRESS_SHMEM_H__
#define __COMPRESS_SHMEM_H__

#include <stdint.h>
enum {BUF_HAS_DATA_FOR_CLIENT, BUF_HAS_DATA_FOR_SERVER, BUF_UNUSED};
struct shmeminterface {
    uint32_t buffersize;
    uint32_t bufferstart;
    uint32_t bufferstate;

    shmeminterface()
        : buffersize(0), bufferstart(0), bufferstate(BUF_UNUSED)
    {
    }
};
#endif
