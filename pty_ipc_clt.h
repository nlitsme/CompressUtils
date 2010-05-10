#ifndef __PTY_IPC_CLT_H__
#define __PTY_IPC_CLT_H__
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <util.h>       // openpty

#include "stringutils.h"
#include "posixerr.h"
#include "readwriter.h"
#include "forkchild.h"

class pty_ipc_client : public readwriter, public fork_child {
    int _pty;
    int _tty;
    char _ttydev[PATH_MAX];

public:
    pty_ipc_client(const std::string& svrname, const StringList& args)
    {
        int rc = openpty(&_pty, &_tty, _ttydev, NULL, NULL);
        if (rc < 0) { 
            throw posixerror("openpty");
        }
        fprintf(stderr, "openpty -> %d, %d : %s\n", _pty, _tty, _ttydev);

//      signal(SIGUSR1, do_nothing); /* don't die */
//      signal(SIGCHLD, do_nothing); /* don't ignore SIGCHLD */

        StringList ptyargs;
#ifndef PTY_TO_STDIO
        ptyargs.push_back(_ttydev);
#endif
        ptyargs.insert(ptyargs.end(), args.begin(), args.end());
        run_child(svrname, ptyargs);

        close(_pty);
        fprintf(stderr, "parent is using %d\n", _tty);
    }
    virtual void initialize_child()
    {
        close(_tty);
        fprintf(stderr, "child is using %d\n", _pty);

#ifdef PTY_TO_STDIO
        if (-1==dup2(_pty, STDIN_FILENO))
            throw posixerror("dup2(stdin)");
        if (-1==dup2(_pty, STDOUT_FILENO))
            throw posixerror("dup2(stdout)");

        close(_pty);
#endif
//      signal(SIGUSR1, SIG_DFL);
    }
    ~pty_ipc_client()
    {
        close(_tty);
    }
    virtual size_t readsome(void*p, size_t n)
    {
        return ::read(_tty, p, n);
    }

    virtual size_t writesome(const void*p, size_t n)
    {
        return ::write(_tty, p, n);
    }
};

#endif

